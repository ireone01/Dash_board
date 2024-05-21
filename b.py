from flask import Flask, render_template
from flask_socketio import SocketIO, emit
import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from sqlalchemy import create_engine
import json

app = Flask(__name__)
socketio = SocketIO(app)

# Thông tin kết nối tới SQL Server
server = 'ADMIN-PC\\IREONE01'
database = 'huy1'
username = 'sa'
password = '12345'
connection_string = f'mssql+pyodbc://{username}:{password}@{server}/{database}?driver=SQL+Server'

# Tạo engine kết nối
engine = create_engine(connection_string)

def get_dashboard_data():
    query = '''
    SELECT ThoiGian, TongDoanhThu, TyLeLapDay, SoHopDongGiaHan, SoHopDongMoi
    FROM KPI
    '''
    df = pd.read_sql(query, engine)

    # Chuyển đổi cột ThoiGian thành kiểu datetime nếu cần thiết
    df['ThoiGian'] = pd.to_datetime(df['ThoiGian'])

    df['KPI_TongDoanhThu'] = 50000
    df['KPI_TyLeLapDay'] = 70
    df['KPI_SoHopDongGiaHan'] = 50
    df['KPI_SoHopDongMoi'] = 25

    fig = make_subplots(rows=2, cols=2, subplot_titles=('TongDoanhThu', 'TyLeLapDay', 'SoHopDongGiaHan', 'SoHopDongMoi'))

    fig.add_trace(go.Scatter(x=df['ThoiGian'], y=df['TongDoanhThu'], mode='lines+markers', name='TongDoanhThu'), row=1, col=1)
    fig.add_trace(go.Scatter(x=df['ThoiGian'], y=df['KPI_TongDoanhThu'], mode='lines', name='KPI', line=dict(dash='dash', color='red')), row=1, col=1)

    fig.add_trace(go.Scatter(x=df['ThoiGian'], y=df['TyLeLapDay'], mode='lines+markers', name='TyLeLapDay'), row=1, col=2)
    fig.add_trace(go.Scatter(x=df['ThoiGian'], y=df['KPI_TyLeLapDay'], mode='lines', name='KPI', line=dict(dash='dash', color='red')), row=1, col=2)

    fig.add_trace(go.Scatter(x=df['ThoiGian'], y=df['SoHopDongGiaHan'], mode='lines+markers', name='SoHopDongGiaHan'), row=2, col=1)
    fig.add_trace(go.Scatter(x=df['ThoiGian'], y=df['KPI_SoHopDongGiaHan'], mode='lines', name='KPI', line=dict(dash='dash', color='red')), row=2, col=1)

    fig.add_trace(go.Scatter(x=df['ThoiGian'], y=df['SoHopDongMoi'], mode='lines+markers', name='SoHopDongMoi'), row=2, col=2)
    fig.add_trace(go.Scatter(x=df['ThoiGian'], y=df['KPI_SoHopDongMoi'], mode='lines', name='KPI', line=dict(dash='dash', color='red')), row=2, col=2)

    fig.update_layout(
        title_text='Dashboard KPI',
        showlegend=True,
        height=800,
        width=1000
    )

    table_html = df.to_html(index=False)

    alerts = []

    for index, row in df.iterrows():
        if row['TongDoanhThu'] < row['KPI_TongDoanhThu']:
            alerts.append(f"TongDoanhThu below KPI on {row['ThoiGian'].strftime('%Y-%m-%d')}")
        if row['TyLeLapDay'] < row['KPI_TyLeLapDay']:
            alerts.append(f"TyLeLapDay below KPI on {row['ThoiGian'].strftime('%Y-%m-%d')}")
        if row['SoHopDongGiaHan'] < row['KPI_SoHopDongGiaHan']:
            alerts.append(f"SoHopDongGiaHan below KPI on {row['ThoiGian'].strftime('%Y-%m-%d')}")
        if row['SoHopDongMoi'] < row['KPI_SoHopDongMoi']:
            alerts.append(f"SoHopDongMoi below KPI on {row['ThoiGian'].strftime('%Y-%m-%d')}")

    return fig.to_json(), table_html, alerts

@app.route('/')
def index():
    return render_template('index.html')

@socketio.on('connect')
def handle_connect(auth):
    fig_json, table_html, alerts = get_dashboard_data()
    emit('update_dashboard', {'fig': fig_json, 'table': table_html, 'alerts': alerts})

@socketio.on('request_update')
def handle_request_update():
    fig_json, table_html, alerts = get_dashboard_data()
    emit('update_dashboard', {'fig': fig_json, 'table': table_html, 'alerts': alerts})

if __name__ == '__main__':
    socketio.run(app, debug=True, allow_unsafe_werkzeug=True)
