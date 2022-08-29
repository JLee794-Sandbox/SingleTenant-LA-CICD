import logging, datetime
from operator import truediv

import azure.functions as func

from datetime import datetime

def main(msg: func.ServiceBusMessage):
    logging.info('[SvcBusTrigger]Python ServiceBus queue trigger processed message: %s',
                 msg.get_body().decode('utf-8'))

    # logging.info(dir(msg))
    # logging.info(vars(msg))
    
    session_id = msg.session_id
    current_time = datetime.now()
    exec_time = msg.enqueued_time_utc

    logging.info(f'\n[SvcBusTrigger SessionID: {session_id}]\n\tCurrent time: {current_time} \n\tExecution time: {exec_time}')
    # logging.info(result)
