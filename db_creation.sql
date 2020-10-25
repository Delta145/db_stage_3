CREATE TABLE адрес (
	id SERIAL PRIMARY KEY,
	страна TEXT,
	субъект TEXT,
	муниципальный_район TEXT,
	городское_или_сельское_поселение TEXT,
	планировочная_структура TEXT,
	улица TEXT,
	номер_земельного_участка TEXT,
	номер_здания TEXT,
	номер_помещения TEXT
);

CREATE TABLE кофейня (
	id SERIAL PRIMARY KEY,
	адрес INTEGER REFERENCES адрес (id) NOT NULL,
	телефон TEXT NOT NULL,
);

CREATE TABLE товар (
	id SERIAL PRIMARY KEY,
	название TEXT NOT NULL,
	стоимость REAL NOT NULL,
вес FLOAT NOT NULL,
	фото BYTEA
);

CREATE TABLE десерт (
	id INTEGER PRIMARY KEY,
	товар INTEGER REFERENCES товар (id) NOT NULL UNIQUE,
	калории FLOAT NOT NULL
CONSTRAINT товар CHECK (id = товар)
);

CREATE TABLE клиент (
	id SERIAL PRIMARY KEY,
	имя TEXT NOT NULL,
	фамилия TEX	T NOT NULL,
	пол CHAR(1) NOT NULL CHECK (пол = 'М' OR пол = 'Ж'),
	дата_рождения DATE,
	адрес INTEGER REFERENCES адрес (id),
	email TEXT UNIQUE,
	телефон TEXT NOT NULL UNIQUE
);

CREATE TABLE рецепт (
	id SERIAL PRIMARY KEY,
	клиент INTEGER REFERENCES клиент(id) NOT NULL
);

CREATE TABLE кофе (
	id INTEGER PRIMARY KEY,
	товар INTEGER REFERENCES товар (id) NOT NULL UNIQUE,
	тип TEXT NOT NULL,
	рецепт INTEGER REFERENCES рецепт (id) NOT NULL UNIQUE,
состояние CHAR(1) NOT NULL
	CONSTRAINT товар CHECK (id = товар)
);

CREATE TABLE ингредиент (
	id SERIAL PRIMARY KEY,
	название TEXT NOT NULL,
	стоимость FLOAT NOT NULL,
	калории FLOAT NOT NULL,
	количество_мл FLOAT NOT NULL,
);

CREATE TABLE компонент_рецепта (
	id SERIAL PRIMARY KEY,
	рецепт INTEGER REFERENCES рецепт (id) NOT NULL,
	ингредиент INTEGER REFERENCES ингредиент (id) NOT NULL,
	количество INTEGER NOT NULL CHECK (количество > 0),
	порядок_добавления INTEGER NOT NULL CHECK (порядок_добавления  > 0)
);

CREATE TABLE заказ (
	id SERIAL PRIMARY KEY,
	статус_заказа CHAR(1) NOT NULL,
	клиент INTEGER REFERENCES клиент (id) NOT NULL,
	кофейня INTEGER REFERENCES кофейня (id) NOT NULL,
	стоимость FLOAT,
	время_формирования TIMESTAMP NOT NULL
);

CREATE TABLE компонент_заказа (
	id SERIAL PRIMARY KEY,
	заказ INTEGER REFERENCES заказ (id) NOT NULL,
	товар INTEGER REFERENCES товар (id) NOT NULL,
	скидка FLOAT NOT NULL CHECK (скидка >= 0.0 AND скидка <= 100)
);

CREATE TABLE расписание (
	id SERIAL PRIMARY KEY,
	название VARCHAR(32) NOT NULL,
	клиент INTEGER REFERENCES клиент (id) NOT NULL,
	описание TEXT,
	состояние CHAR(1) NOT NULL
);

CREATE TABLE запись_расписания (
	id SERIAL PRIMARY KEY,
	название TEXT NOT NULL,
	расписание INTEGER REFERENCES расписание (id) NOT NULL,
	заказ INTEGER REFERENCES заказ (id) NOT NULL,
	периодичность INTEGER NOT NULL
);

CREATE TABLE оценка (
	id SERIAL PRIMARY KEY,
	оценка INTEGER CHECK (оценка >= 0 AND оценка <= 5) NOT NULL,
	отзыв TEXT NOT NULL
);

CREATE TABLE оценка_кофе (
	id INTEGER PRIMARY KEY,
	оценка INTEGER REFERENCES оценка (id) NOT NULL UNIQUE,
	кофе INTEGER REFERENCES кофе (id) NOT NULL,
	CONSTRAINT оценка CHECK (id = оценка)
);

CREATE TABLE оценка_расписания (
	id INTEGER PRIMARY KEY,
	оценка INTEGER REFERENCES оценка (id) NOT NULL UNIQUE,
	расписание INTEGER REFERENCES расписание (id) NOT NULL,
	CONSTRAINT оценка CHECK (id = оценка)
);

CREATE TABLE любимые_расписания (
	id SERIAL PRIMARY KEY,
	клиент INTEGER REFERENCES клиент (id) NOT NULL,
	расписание INTEGER REFERENCES расписание (id) NOT NULL
);

CREATE TABLE любимые_кофе (
	id SERIAL PRIMARY KEY,
	клиент INTEGER REFERENCES клиент (id) NOT NULL,
	кофе INTEGER REFERENCES кофе (id) NOT NULL
);
