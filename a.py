import dash
from dash import dcc, html
import dash_bootstrap_components as dbc
import pandas as pd
import plotly.express as px
from dash.dependencies import Input, Output
from sqlalchemy import create_engine

# Kết nối cơ sở dữ liệu sử dụng SQLAlchemy
engine = create_engine(r'mssql+pyodbc://sa:12345@ADMIN-PC\IREONE01/huy1?driver=ODBC+Driver+17+for+SQL+Server')

# Truy xuất dữ liệu từ bảng KPI
query = "SELECT * FROM KPI"
df_kpi = pd.read_sql(query, engine)

# Chuyển đổi định dạng datetime
df_kpi['ThoiGian'] = pd.to_datetime(df_kpi['ThoiGian'])
df_kpi['Year'] = df_kpi['ThoiGian'].dt.year
df_kpi['Quarter'] = df_kpi['ThoiGian'].dt.to_period('Q').astype(str)

# Tính toán tăng trưởng doanh thu
df_kpi = df_kpi.sort_values('ThoiGian')
df_kpi['TongDoanhThu_Lag'] = df_kpi['TongDoanhThu'].shift(4)
df_kpi['TangTruongDoanhThu'] = ((df_kpi['TongDoanhThu'] - df_kpi['TongDoanhThu_Lag']) / df_kpi['TongDoanhThu_Lag']) * 100

# Thay thế các giá trị NaN bằng 0
df_kpi['TangTruongDoanhThu'] = df_kpi['TangTruongDoanhThu'].fillna(0)

# Tạo biểu đồ tăng trưởng doanh thu theo quý và theo năm
fig_growth = px.line(df_kpi, x='Quarter', y='TangTruongDoanhThu', color='Year', title='Tăng Trưởng Doanh Thu Theo Quý')

# Tạo các chỉ số chính (ví dụ, điều chỉnh nếu cần)
total_revenue = df_kpi['TongDoanhThu'].sum() if not df_kpi.empty else 0
current_revenue = df_kpi['TongDoanhThu'].iloc[-1] if not df_kpi.empty else 0
total_rooms_rented = df_kpi['SoPhongTrong'].sum() if 'SoPhongTrong' in df_kpi else 0
new_contracts = df_kpi['SoHopDongMoi'].sum() if 'SoHopDongMoi' in df_kpi else 0

indicators = [
    {"title": "Tổng Doanh Thu", "value": total_revenue},
    {"title": "Doanh Thu năm Hiện Tại", "value": current_revenue},
    {"title": "Số Phòng Được Thuê Trong Quý", "value": total_rooms_rented},
    {"title": "Số Hợp Đồng Mới Ký Trong Quý", "value": new_contracts}
]

# Khởi tạo ứng dụng Dash
app = dash.Dash(__name__, external_stylesheets=[dbc.themes.BOOTSTRAP])

app.layout = dbc.Container([
    dbc.Row([
        dbc.Col(html.Div([
            html.Label("CHỌN QUÝ BC", className="header-label"),
            dcc.Dropdown(
                id='quy-dropdown',
                options=[{'label': f'Q{i}', 'value': i} for i in range(1, 5)],
                value=1,
                clearable=False,
                className="dropdown"
            ),
            html.H3("Năm 2023", className="header-year")
        ]), width=4),
        dbc.Col(html.Div(id='output'), width=8)
    ], className="header-row"),
    dbc.Row([
        dbc.Col(html.Div([
            html.Div([
                html.Div([
                    html.P(indicator["title"], className="indicator-title"),
                    html.H3(f'{indicator["value"]:,}', className="indicator-value")
                ], className="indicator-box")
                for indicator in indicators
            ], className="indicator-container")
        ]), width=12)
    ]),
    dbc.Row([
        dbc.Col(dcc.Graph(figure=fig_growth), width=12, className="card")
    ])
], fluid=True, className="main-container")

app.index_string = '''
<!DOCTYPE html>
<html>
    <head>
        {%metas%}
        <title>Dashboard Cho Thuê Trọ</title>
        {%favicon%}
        {%css%}
        <style>
            .header-label {
                font-weight: bold;
                font-size: 1.2em;
            }
            .header-year {
                font-size: 1.5em;
                margin-top: 10px;
            }
            .dropdown {
                margin-top: 5px;
            }
            .header-row {
                background-color: #f8f9fa;
                padding: 15px;
                border-radius: 5px;
                margin-bottom: 15px;
            }
            .main-container {
                margin: 0 auto;
                padding: 20px;
                max-width: 1200px;
            }
            .indicator-container {
                display: flex;
                justify-content: space-around;
                margin-bottom: 30px;
            }
            .indicator-box {
                border: 1px solid #ccc;
                border-radius: 5px;
                padding: 10px;
                width: 23%;
                text-align: center;
                background-color: #fff;
            }
            .indicator-title {
                font-size: 1em;
                font-weight: bold;
                margin: 0;
            }
            .indicator-value {
                font-size: 1.5em;
                color: green;
                margin: 5px 0 0 0;
            }
            .card {
                padding: 15px;
                border-radius: 5px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                margin-bottom: 15px;
            }
            .card .dash-graph {
                height: 100%;
            }
        </style>
    </head>
    <body>
        {%app_entry%}
        <footer>
            {%config%}
            {%scripts%}
            {%renderer%}
        </footer>
    </body>
</html>
'''

if __name__ == '__main__':
    app.run_server(debug=True)
