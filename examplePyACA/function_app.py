import azure.functions as func
from http_example_blueprint import bphe

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

app.register_functions(bphe)
