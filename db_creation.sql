CREATE TABLE адрес
(
    id                               SERIAL PRIMARY KEY,
    страна                           TEXT,
    субъект                          TEXT,
    муниципальный_район              TEXT,
    городское_или_сельское_поселение TEXT,
    планировочная_структура          TEXT,
    улица                            TEXT,
    номер_земельного_участка         TEXT,
    номер_здания                     TEXT,
    номер_помещения                  TEXT
);

CREATE TABLE кофейня
(
    id        SERIAL PRIMARY KEY,
    id_адреса INTEGER REFERENCES адрес (id) NOT NULL,
    телефон   TEXT                          NOT NULL
);

CREATE TABLE товар
(
    id        SERIAL PRIMARY KEY,
    название  TEXT NOT NULL,
    стоимость REAL,
    вес       FLOAT,
    фото      BYTEA
);

CREATE TABLE десерт
(
    id        INTEGER PRIMARY KEY,
    id_товара INTEGER REFERENCES товар (id) ON DELETE CASCADE NOT NULL UNIQUE,
    калории   FLOAT                                           NOT NULL
        CONSTRAINT товар CHECK (id = id_товара)
);

CREATE TABLE клиент
(
    id            SERIAL PRIMARY KEY,
    имя           TEXT    NOT NULL,
    фамилия       TEXT    NOT NULL,
    пол           CHAR(1) NOT NULL CHECK (пол = 'М' OR пол = 'Ж'),
    дата_рождения DATE,
    id_адреса     INTEGER REFERENCES адрес (id),
    email         TEXT UNIQUE,
    телефон       TEXT    NOT NULL UNIQUE
);

CREATE TABLE кофе
(
    id        INTEGER PRIMARY KEY,
    id_товара INTEGER REFERENCES товар (id) ON DELETE CASCADE NOT NULL UNIQUE,
    тип       CHAR                                            NOT NULL CHECK (тип IN ('u', 's') ),
    id_автора INTEGER REFERENCES клиент (id)                  NOT NULL,
    состояние TEXT                                            NOT NULL
        CONSTRAINT товар CHECK (id = id_автора)
);

CREATE TABLE ингредиент
(
    id            SERIAL PRIMARY KEY,
    название      TEXT  NOT NULL,
    стоимость     FLOAT NOT NULL,
    количество_мл FLOAT NOT NULL
);

CREATE TABLE компонент_кофе
(
    id                 SERIAL PRIMARY KEY,
    id_кофе            INTEGER REFERENCES кофе (id) ON DELETE CASCADE NOT NULL,
    id_ингредиента     INTEGER REFERENCES ингредиент (id)             NOT NULL,
    количество         INTEGER                                        NOT NULL CHECK (количество > 0),
    порядок_добавления INTEGER                                        NOT NULL CHECK (порядок_добавления > 0)
);

CREATE TABLE заказ
(
    id                 SERIAL PRIMARY KEY,
    статус_заказа      CHAR(1)                         NOT NULL,
    id_клиента         INTEGER REFERENCES клиент (id)  NOT NULL,
    id_кофейни         INTEGER REFERENCES кофейня (id) NOT NULL,
    стоимость          FLOAT,
    время_формирования TIMESTAMP                       NOT NULL,
    скидка             FLOAT CHECK (скидка >= 0.0 AND скидка <= 100)
);

CREATE TABLE компонент_заказа
(
    id        SERIAL PRIMARY KEY,
    id_заказа INTEGER REFERENCES заказ (id) ON DELETE CASCADE NOT NULL,
    id_товара INTEGER REFERENCES товар (id)                   NOT NULL
);

CREATE TABLE расписание
(
    id         SERIAL PRIMARY KEY,
    название   VARCHAR(32)                    NOT NULL,
    id_клиента INTEGER REFERENCES клиент (id) NOT NULL,
    описание   TEXT,
    состояние  TEXT                           NOT NULL
);

CREATE TABLE запись_расписания
(
    id            SERIAL PRIMARY KEY,
    название      TEXT                                                 NOT NULL,
    id_расписания INTEGER REFERENCES расписание (id) ON DELETE CASCADE NOT NULL,
    id_заказа     INTEGER REFERENCES заказ (id)                        NOT NULL,
    день_недели   INTEGER                                              NOT NULL,
    время         TIME                                                 NOT NULL
);

CREATE TABLE оценка
(
    id     SERIAL PRIMARY KEY,
    оценка INTEGER CHECK (оценка >= 0 AND оценка <= 5) NOT NULL,
    отзыв  TEXT                                        NOT NULL
);

CREATE TABLE оценка_кофе
(
    id        INTEGER PRIMARY KEY,
    id_оценки INTEGER REFERENCES оценка (id)                 NOT NULL UNIQUE,
    id_кофе   INTEGER REFERENCES кофе (id) ON DELETE CASCADE NOT NULL,
    CONSTRAINT оценка CHECK (id = id_оценки)
);

CREATE TABLE оценка_расписания
(
    id            INTEGER PRIMARY KEY,
    id_оценки     INTEGER REFERENCES оценка (id)                       NOT NULL UNIQUE,
    id_расписания INTEGER REFERENCES расписание (id) ON DELETE CASCADE NOT NULL,
    CONSTRAINT оценка CHECK (id = id_оценки)
);

CREATE TABLE любимые_расписания
(
    id            SERIAL PRIMARY KEY,
    id_клиента    INTEGER REFERENCES клиент (id)                       NOT NULL,
    id_расписания INTEGER REFERENCES расписание (id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE любимые_кофе
(
    id         SERIAL PRIMARY KEY,
    id_клиента INTEGER REFERENCES клиент (id)                 NOT NULL,
    id_кофе    INTEGER REFERENCES кофе (id) ON DELETE CASCADE NOT NULL
);
