import dash
from dash import dcc, html
import dash_bootstrap_components as dbc
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go

# Sample data
df_main = pd.DataFrame({
    'Quy': [f'Q{i}' for i in range(1, 5)],
    'TongDoanhThu': [20717175575, 1666023008, 1366, 107],
    'SoPhongDuocThue': [150, 120, 130, 140],
    'SoHopDongMoi': [30, 25, 28, 32]
})

df_group = pd.DataFrame({
    'Tang': ['Tầng 1', 'Tầng 2', 'Tầng 3', 'Tầng 4', 'Tầng 5'],
    'DoanhThuTang': [722, 399, 138, 398, 472],
    'LoiNhuanHDKD': [50, 62, 58, 78, 90]
})

df_sales = pd.DataFrame({
    'Nam': [2023, 2023, 2023, 2023, 2024, 2024, 2024, 2024],
    'Quy': ['Q1', 'Q2', 'Q3', 'Q4', 'Q1', 'Q2', 'Q3', 'Q4'],
    'DoanhThuHang': [100, 120, 150, 130, 160, 140, 170, 180],
    'TangTruongDoanhThu': [100, 120, 110, 130, 120, 110, 140, 130]
})

# Filter data for the current year (2024)
current_year = 2024
df_sales_current_year = df_sales[df_sales['Nam'] == current_year]

# Convert data to long form
df_sales_long = df_sales.melt(id_vars=['Nam', 'Quy'], value_vars=['DoanhThuHang', 'TangTruongDoanhThu'],
                              var_name='Metric', value_name='Value')

# Create figures for main indicators
indicators = [
    {"title": "Tổng Doanh Thu", "value": df_main['TongDoanhThu'][0]},
    {"title": "Doanh Thu năm Hiện Tại", "value": df_main['TongDoanhThu'][1]},
    {"title": "Số Phòng Được Thuê Trong Quý", "value": df_main['SoPhongDuocThue'][2]},
    {"title": "Số Hợp Đồng Mới Ký Trong Quý", "value": df_main['SoHopDongMoi'][3]}
]

# Create figures for other charts
fig5 = px.bar(df_group, x='Tang', y='DoanhThuTang', title='Doanh Thu Theo Tầng')
fig6 = px.bar(df_group, x='Tang', y='LoiNhuanHDKD', title='Lợi Nhuận Kinh Doanh Theo Tầng')

fig7 = go.Figure(go.Indicator(
    mode="gauge+number",
    value=85,  # Example occupancy rate value
    title="Độ Lấp Đầy Phòng",
    gauge={'axis': {'range': [0, 100]},
           'bar': {'color': "green"}},
))

fig8 = px.bar(df_sales_current_year, x='Quy', y='DoanhThuHang', title='Doanh Thu Theo Quý')

fig9 = px.line(df_sales, x='Quy', y='TangTruongDoanhThu', color='Nam', title='Tăng Trưởng Doanh Thu Theo Quý')

fig10 = go.Figure(go.Indicator(
    mode="gauge+number",
    value=75,  # Example renewal rate value
    title="Tỷ Lệ Tái Ký",
    gauge={'axis': {'range': [0, 100]},
           'bar': {'color': "blue"}},
))

# Tạo ô tăng trưởng doanh thu
growth_fig = go.Figure(go.Indicator(
    mode="number+delta",
    value=-3,
    delta={"reference": 0, "position": "bottom", "relative": False},
    title={"text": "Tăng Trưởng Doanh Thu"},
    number={"suffix": "%"}
))

# Initialize Dash app
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
        dbc.Col(dcc.Graph(figure=growth_fig), width=3, className="card"),
        dbc.Col(dcc.Graph(figure=fig7), width=3, className="card"),
        dbc.Col(dcc.Graph(figure=fig5), width=6, className="card")
    ]),
    dbc.Row([
        dbc.Col(dcc.Graph(figure=fig6), width=6, className="card"),
        dbc.Col(dcc.Graph(figure=fig8), width=6, className="card")
    ]),
    dbc.Row([
        dbc.Col(dcc.Graph(figure=fig9), width=6, className="card"),
        dbc.Col(dcc.Graph(figure=fig10), width=6, className="card")
    ])
], fluid=True, className="main-container")

app.css.append_css({
    "external_url": "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"
})

app.css.append_css({
    "external_url": "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css"
})

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
