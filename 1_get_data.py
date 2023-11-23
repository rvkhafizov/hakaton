import aiohttp
import asyncio
import time
import os
import json

import logging

start_time = time.time()
token = '000000000' #здесь нужно прописать реальный токен


#инициализаци логера
log = logging.getLogger('log')
log.setLevel(logging.DEBUG)
handler = logging.FileHandler(os.path.join('log', 'log.txt'))
format = logging.Formatter('%(asctime)s  %(name)s %(levelname)s: %(message)s')
handler.setFormatter(format)
log.addHandler(handler)


async def get_data(session, url):
    async with session.get(url) as resp:
        result = None
        try:
            result = await resp.json()
        except Exception as e:
            log.info(e)
        return result


async def main():

    async with aiohttp.ClientSession() as session:

        for page in range(1, 100001):

            path = os.path.join('data', f'{page}.json')

            if not os.path.isfile(path):

                url = f'http://185.185.70.194/api/{page}?token={token}'
                task = asyncio.create_task(get_data(session, url))
                result_json = await task
                await asyncio.sleep(3)

                if result_json is not None and result_json['response'] is not None:
                    with open(path, 'w', encoding='utf-8') as f:
                        json.dump(result_json, f, ensure_ascii=False, indent=4)
                else:
                    msg = f'не удалось скачать страницу ' + str(page)
                    log.info(msg)


if __name__ == "__main__":

    log.info('Starting...')

    # запуск асинхронного цикла получения данных
    loop = asyncio.get_event_loop()  # создаем цикл
    task = loop.create_task(main())
    loop.run_until_complete(task)  # ждем окончания выполнения цикла

    print("--- %s seconds ---" % (time.time() - start_time))