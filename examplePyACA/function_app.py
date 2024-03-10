import azure.functions as func
import azure.durable_functions as df
from http_example_blueprint import bp_he
from http_example_dr_blueprint import he_dr_bp

app = df.DFApp(http_auth_level=func.AuthLevel.ANONYMOUS)

app.register_functions(bp_he)
app.register_functions(he_dr_bp)
