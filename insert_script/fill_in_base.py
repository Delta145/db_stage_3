import subprocess
from itertools import product
from datetime import datetime, timedelta
from random import random, choice
from string import ascii_letters


# def insert_into(table, fields, values):
# 	command = f'INSERT INTO {table} ({", ".join(fields)}) VALUES ({", ".join(values)});'
# 	subprocess.run(['psql', f'--command={command}'])

def insert_into(table, fields, values):
    values = [str(v) for v in values]
    command = f'INSERT INTO {table} ({", ".join(fields)}) VALUES ({", ".join(values)});\n'
    with open('insert_script.sql', 'a', encoding='utf-8') as f:
        f.write(command)


def generate_random_email(already_generated=[]):
    endings = ['gmail', 'mail', 'yandex']
    domens = ['ru', 'com', 'ua']
    max_length = 20
    min_length = 5

    while True:
        email = "".join([choice(ascii_letters) for _ in
                         range(int(random() * max_length) + min_length)
                         ])
        email = f'{email}@{choice(endings)}.{choice(domens)}'
        if email in already_generated:
            continue
        else:
            already_generated.append(email)
            return email


def generate_random_phone(already_generated=[]):
    numbers = "".join([str(a) for a in range(10)])
    length = 11

    while True:
        phone = f'+{"".join([choice(numbers) for _ in range(length)])}'
        'and {} {}'.format(phone, phone)
        if phone in already_generated:
            continue
        else:
            already_generated.append(phone)
            return phone


def getRandomDate(start_date, interval_days):
    return (datetime.strptime(start_date, '%Y-%m-%d') + timedelta(days=int(random() * interval_days))).strftime(
        '%Y-%m-%d')


if __name__ == '__main__':
    with open('insert_script.sql', 'w') as f:
        f.write('')
    COFFEE_AMOUNT = 440
    PERSON_AMOUNT = 10_000
    STD_AMOUNT = 100
    PRODUCTS_AMOUNT = 453
    START_WORK = 8
    END_WORK = 20

    adress_amount = 0
    with open("data_adr.csv", 'r', encoding='utf-8') as f:
        for s in f.readlines():
            arr = s.replace("\n", "").split(";")
            arr = [f'\'{a}\'' for a in arr]
            adress_amount += 1
            table_name = "адрес"
            fields = ['страна', 'субъект', 'муниципальный_район', 'поселение', 'населенный_пункт',
                      'планировочная_структура', 'улица', 'номер_земельного_участка', 'номер_здания', 'номер_помещения']
            values = ["'Российская Федерация'", *arr]
            insert_into(table_name, fields, values)

    names = []
    surnames = []
    with open("russian_names.csv", 'r', encoding='utf-8') as f:
        for s in f.readlines():
            arr = s.replace("\n", "").split(";")
            names.append({
                'name': arr[1],
                'sex': arr[2]
            })

    with open("russian_surnames.csv", 'r', encoding='utf-8') as f:
        for s in f.readlines():
            arr = s.replace("\n", "").split(";")
            surnames.append(arr[1])

    start_date = datetime(year=1940, month=1, day=1)
    SEVENTY_YEARS_DAYS = 365 * 70


    def person_generator(num):
        for i, ps in enumerate(product(names, surnames)):
            p, s = ps
            yield {
                'имя': f"'{p['name']}'",
                'фамилия': f"'{s}'",
                'пол': f"'{p['sex']}'",
                'дата_рождения': f"'{(start_date + timedelta(days=int(random() * SEVENTY_YEARS_DAYS))).strftime('%Y-%m-%d')}'",
                'email': f"'{generate_random_email()}'",
                'id_адреса': int(random() * (adress_amount - 100)) + 100,
                'телефон': f"'{generate_random_phone()}'"
            }
            if i >= num:
                break


    for s in person_generator(PERSON_AMOUNT):
        table_name = "клиент"
        fields = list(s.keys())
        values = [f'{i}' for i in s.values()]
        insert_into(table_name, fields, values)

    for i in range(STD_AMOUNT):
        table_name = "кофейня"
        fields = ['id_адреса', 'телефон']
        values = [str(i), generate_random_phone()]
        insert_into(table_name, fields, values)

    products = []
    with open("products.csv", 'r', encoding='utf-8') as f:
        table_name = "товар"
        fields = ['название', 'стоимость']
        for s in f.readlines():
            arr = s.replace("\n", "").split(";")
            values = [f"'{arr[0]}'", arr[1]]
            products.append({
                'name': arr[0],
                'price': int(arr[1])
            })
            insert_into(table_name, fields, values)
    with open("adjectives.csv", 'r', encoding='utf-8') as f:
        table_name = "товар"
        fields = ['название', 'стоимость']
        for s in f.readlines():
            cost = choice(range(90, 300))
            arr = s.replace("\n", "").split(";")
            values = [arr[0], cost]
            products.append({
                'name': arr[0],
                'price': int(cost)
            })
            insert_into(table_name, fields, values)

    with open("dessert.csv", 'r', encoding='utf-8') as f:
        table_name = "десерт"
        fields = ['id', 'id_товара', 'калории', 'вес']
        for s in f.readlines():
            arr = s.replace("\n", "").split(";")
            values = arr[:4]
            insert_into(table_name, fields, values)

    state = ['редакция', 'опубликовано', 'скрыто']
    id = 13
    with open("coffee.csv", 'r', encoding='utf-8') as f:
        for s in f.readlines():
            id += 1
            arr = s.replace("\n", "").split(";")
            table_name = "кофе"
            fields = ['id', 'id_товара', 'тип', 'состояние', 'id_автора']
            values = [arr[0], arr[0], arr[1], f"'{choice(state)}'", choice(range(PERSON_AMOUNT))]
            insert_into(table_name, fields, values)
            for i in range(choice(range(1, 10))):
                table_name = "компонент_кофе"
                fields = ['id_кофе', 'id_ингредиента', 'количество', 'порядок_добавления']
                values = [str(id), choice(range(1, 28)), choice(range(1, 10)), str(i)]
                insert_into(table_name, fields, values)

    state = ['формируется', 'готовится', 'готов', 'получен']
    for order_number in range(1, STD_AMOUNT):
        component = []
        result_cost = 0
        for i in range(choice(range(10))):
            id_product = choice(range(1, PRODUCTS_AMOUNT))
            result_cost += products[id_product]['price']
            values = [order_number, id_product]
            component.append(values)
        discount = round(random(), 2)
        result_cost -= result_cost * discount
        table_name = "заказ"
        fields = ['статус_заказа', 'id_клиента', 'id_кофейни', 'скидка', 'стоимость', 'время_формирования']
        values = [
            f"'{choice(state)}'",
            choice(range(PERSON_AMOUNT)),
            choice(range(STD_AMOUNT)),
            discount, result_cost,
            f"'{getRandomDate('2015-01-01', 5 * 365)} {choice(range(START_WORK, END_WORK + 1))}:{choice(range(59))}'"

        ]
        insert_into(table_name, fields, values)
        table_name = "компонент_заказа"
        fields = ['id_заказа', 'id_товара']
        for i in component:
            insert_into(table_name, fields, i)

    with open("ingredients.csv", 'r', encoding='utf-8') as f:
        table_name = "ингредиент"
        fields = ['название', 'стоимость', 'количество_мл']
        for s in f.readlines():
            arr = s.replace("\n", "").split(";")
            values = arr[:3]
            insert_into(table_name, fields, values)

    id = 0
    state = ['редакция', 'опубликовано', 'скрыто']
    for i in range(STD_AMOUNT):
        id += 1
        table_name = "расписание"
        fields = ['id_клиента', 'состояние']
        values = [choice(range(PERSON_AMOUNT)), f"'{choice(state)}'"]
        insert_into(table_name, fields, values)
        for j in range(7):
            table_name = "запись_расписания"
            fields = ['id_расписания', 'id_заказа', 'день_недели', 'время']
            values = [
                id,
                choice(range(1, STD_AMOUNT)),
                choice(range(1, 8)),
                f"'{choice(range(START_WORK, END_WORK + 1))}:{choice(range(59))}'"
            ]
            insert_into(table_name, fields, values)

    for i in range(STD_AMOUNT):
        table_name = "любимые_кофе"
        fields = ['id_клиента', 'id_кофе']
        values = [
            choice(range(PERSON_AMOUNT)),
            choice(range(COFFEE_AMOUNT))
        ]
        insert_into(table_name, fields, values)

    for i in range(STD_AMOUNT):
        table_name = "любимые_расписания"
        fields = ['id_клиента', 'id_расписания']
        values = [choice(range(PERSON_AMOUNT)), choice(range(STD_AMOUNT))]
        insert_into(table_name, fields, values)

    MIN_SCORE = 1
    MAX_SCORE = 5
    id = 0
    with open("adjectives.csv", 'r', encoding='utf-8') as f:
        for i in range(50):
            id += 1
            table_name = "оценка"
            fields = ['оценка', 'отзыв']
            values = [
                choice(range(MIN_SCORE, MAX_SCORE + 1)),
                f.readline()
            ]
            insert_into(table_name, fields, values)
            table_name = "оценка_кофе"
            fields = ['id', 'id_оценки', 'id_кофе']
            values = [
                id,
                id,
                choice(range(COFFEE_AMOUNT))
            ]
            insert_into(table_name, fields, values)
        for i in range(50, 100):
            id += 1
            table_name = "оценка"
            fields = ['оценка', 'отзыв']
            values = [
                choice(range(MIN_SCORE, MAX_SCORE + 1)),
                f.readline()
            ]
            insert_into(table_name, fields, values)
            table_name = "оценка_расписания"
            fields = ['id', 'id_оценки', 'id_расписания']
            values = [
                id,
                id,
                choice(range(STD_AMOUNT))
            ]
            insert_into(table_name, fields, values)
