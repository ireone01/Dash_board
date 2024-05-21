import dash
from dash import dcc, html
import dash_bootstrap_components as dbc
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go

# Sample data
df = pd.DataFrame({
    'ThoiGian': pd.date_range(start='1/1/2023', periods=12, freq='M'),
    'TongDoanhThu': [45000, 48000, 52000, 50000, 47000, 53000, 55000, 51000, 49000, 52000, 54000, 56000],
    'TyLeLapDay': [65, 70, 72, 68, 66, 74, 76, 71, 69, 73, 75, 77],
    'SoHopDongGiaHan': [30, 35, 40, 38, 33, 42, 45, 41, 39, 43, 46, 48],
    'SoHopDongMoi': [20, 22, 25, 24, 21, 26, 28, 27, 23, 29, 30, 32]
})

# Biểu đồ đường cho Tổng Doanh Thu
fig1 = px.line(df, x='ThoiGian', y='TongDoanhThu', title='TongDoanhThu')

# Biểu đồ tròn cho Tỷ lệ Lấp Đầy
fig2 = px.pie(df, values='TyLeLapDay', names='ThoiGian', title='TyLeLapDay')

# Biểu đồ thanh cho Số Hợp Đồng Gia Hạn
fig3 = px.bar(df, x='ThoiGian', y='SoHopDongGiaHan', title='SoHopDongGiaHan')

# Biểu đồ thanh cho Số Hợp Đồng Mới
fig4 = px.bar(df, x='ThoiGian', y='SoHopDongMoi', title='SoHopDongMoi')

# Khởi tạo ứng dụng Dash
app = dash.Dash(__name__, external_stylesheets=[dbc.themes.BOOTSTRAP])

app.layout = dbc.Container([
    dbc.Row([
        dbc.Col(dcc.Graph(figure=fig1), width=6),
        dbc.Col(dcc.Graph(figure=fig2), width=6)
    ]),
    dbc.Row([
        dbc.Col(dcc.Graph(figure=fig3), width=6),
        dbc.Col(dcc.Graph(figure=fig4), width=6)
    ])
], fluid=True)

if __name__ == '__main__':
    app.run_server(debug=True)
