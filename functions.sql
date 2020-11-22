CREATE OR REPLACE FUNCTION createCoffee(coffee_name text, coffee_type char, author int, coffee_state text) RETURNS TEXT STRICT AS $$
DECLARE
ret int;
BEGIN
	INSERT INTO товар(название) VALUES(coffee_name) RETURNING id INTO ret;
	INSERT INTO кофе(id, id_товара, тип, id_автора, состояние) VALUES(ret, ret, coffee_type, author, coffee_state);
	RETURN 'Кофе добавлен, id - ' || ret;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION createDessert(name text, price float, calories float, weight float) RETURNS TEXT STRICT AS $$
DECLARE
ret int;
BEGIN
	INSERT INTO товар(название, стоимость) VALUES(name, price) RETURNING id INTO ret;
	INSERT INTO десерт(id, id_товара, калории, вес) VALUES(ret, ret, calories, weight);
	RETURN 'Десерт добавлен, id - ' || ret;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION addCoffeeRating(rating int, comments text, coffee int) RETURNS TEXT STRICT AS $$
DECLARE
ret int;
BEGIN
	INSERT INTO оценка(оценка, отзыв) VALUES(rating, comments) RETURNING id INTO ret;
	INSERT INTO оценка_кофе(id, id_оценки, id_кофе) VALUES(ret, ret, coffee);
	RETURN 'Оценка на кофе добавлена, id - ' || ret;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION addScheduleRating(rating int, comments text, schedule int) RETURNS TEXT STRICT AS $$
DECLARE
ret int;
BEGIN
	INSERT INTO оценка(оценка, отзыв) VALUES(rating, comments) RETURNING id INTO ret;
	INSERT INTO оценка_расписания(id, id_оценки, id_расписания) VALUES(ret, ret, schedule);
	RETURN 'Оценка на расписание добавлена, id - ' || ret;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION copySchedule(schedule int, client int) RETURNS INT STRICT AS $$
DECLARE
newSchedId int;
BEGIN
INSERT INTO расписание(название, id_клиента, описание, состояние) SELECT название, client, описание, 'E'  FROM расписание WHERE id = schedule RETURNING id INTO newSchedId;
	INSERT INTO запись_расписания(название, id_расписания, id_заказа, день_недели, время) SELECT название, newSchedId, id_заказа, день_недели, время FROM запись_расписания WHERE id_расписания = schedule;
	RETURN newSchedId;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION copyCoffee(coffee int, author int) RETURNS INT STRICT AS $$
DECLARE
newCoffeeId int;
BEGIN
    INSERT INTO товар(название, стоимость, фото) SELECT название, стоимость, фото FROM товар WHERE id = coffee RETURNING id INTO newCoffeeId;
    INSERT INTO кофе(id, id_товара, тип, id_автора, состояние) VALUES (newCoffeeId, newCoffeeId, 'u', author, 'e');
	INSERT INTO компонент_кофе(id_кофе, id_ингредиента, количество, порядок_добавления) SELECT newCoffeeId, id_ингредиента, количество, порядок_добавления FROM компонент_кофе WHERE id_кофе = coffee;
	RETURN newCoffeeId;
END;
$$ LANGUAGE 'plpgsql';