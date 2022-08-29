import os, logging, json
import azure.functions as func

from datetime import datetime, timedelta
from azure.servicebus.aio import ServiceBusClient
from azure.servicebus import ServiceBusMessage


CONNECTION_STR = os.environ['SERVICE_BUS_CONNECTION_STR']
QUEUE_NAME = os.environ["SERVICE_BUS_QUEUE_NAME"]

# Test payload
# {
#     "subject": "test",
#     "count": 5,
#     "interval":5,
#     "frequency": "s",
#     "message": "some message to deliver"
# }

async def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('[HTTPTrigger]Python HTTP trigger has received a new scheduling request.')

    event_name = "FnSvcBusScheduler"

    body = json.loads(req.get_body().decode())
    logging.info(f'[HTTPTrigger]\n\tbody: \n{body}')
    logging.info(body)
    subject = body['subject']
    count = body['count']
    interval = body['interval']
    frequency = body['frequency'] # in "h" "m" "s"

    servicebus_client = ServiceBusClient.from_connection_string(conn_str=CONNECTION_STR, logging_enable=True)

    logging.info(frequency == 'h')
    logging.info(frequency == 'm')
    logging.info(frequency == 's')
    
    for x in range (1, int(count) + 1):
        schedule_time_utc = datetime.utcnow()
        delta = int(interval) * int(x)


        if frequency == 'h':
            schedule_time_utc = schedule_time_utc + timedelta(hours=int(delta))
            logging.info(f'\n\t Hours Offset: {schedule_time_utc}')
        elif frequency == 'm':
            schedule_time_utc = schedule_time_utc + timedelta(minutes=int(delta))
            logging.info(f'\n\t Minutes Offset: {schedule_time_utc}')
        elif frequency == 's':
            schedule_time_utc = schedule_time_utc + timedelta(seconds=int(delta))
            logging.info(f'\n\t Seconds Offset: {schedule_time_utc}')
        else:
            logging.error(f"Invalid frequency: {frequency}. Frequency must be 'h' for hours, 'm' for minutes, or 's' for seconds.")
            exit -1
        logging.info(f"\n\tschedule_time_utc: {schedule_time_utc}\n")
        message = ServiceBusMessage(
                body=(f'{event_name} count {x} of {count} on {interval} interval for \'{frequency}\' frequency scheduled run at {schedule_time_utc}'),
                session_id=subject,
            )
        async with servicebus_client:
            sender = servicebus_client.get_queue_sender(queue_name=QUEUE_NAME)
            async with sender:
                sequence_number = await sender.schedule_messages(message, schedule_time_utc)
                logging.info("\n\t[HTTPTrigger]Scheduled message sequence number: {}\n\n".format(sequence_number))
                # await send_batch_message(sender,arr)

    return func.HttpResponse(f"Successfully scheduled {count} messages for {subject} with {interval} interval for \'{frequency}\' frequency to {QUEUE_NAME} Service Bus Queue")

