import azure.functions as func
import azure.durable_functions as df

he_dr_bp = df.Blueprint()

# An HTTP-Triggered Function with a Durable Functions Client binding
@he_dr_bp.route(route="orchestrators/{functionName}")
@he_dr_bp.durable_client_input(client_name="client")
async def http_start(req: func.HttpRequest, client):
    function_name = req.route_params.get('functionName')
    instance_id = await client.start_new(function_name)
    response = client.create_check_status_response(req, instance_id)
    return response

# Orchestrator
@he_dr_bp.orchestration_trigger(context_name="context")
def hello_orchestrator(context):
    result1 = yield context.call_activity("hello", "Seattle")
    result2 = yield context.call_activity("hello", "Tokyo")
    result3 = yield context.call_activity("hello", "London")

    return [result1, result2, result3]

# Activity
@he_dr_bp.activity_trigger(input_name="city")
def hello(city: str):
    return f"Hello {city}"