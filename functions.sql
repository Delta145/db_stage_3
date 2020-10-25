CREATE OR REPLACE FUNCTION createCoffee(name text, price float, coffee_type text, recipe int, weight int) RETURNS TEXT STRICT AS $$
DECLARE
ret int;
BEGIN
	INSERT INTO товар(название, стоимость, вес) VALUES(name, price, weight) RETURNING id INTO ret;
	INSERT INTO кофе(id, товар, тип, рецепт) VALUES(ret, ret, coffee_type, recipe);
	RETURN 'Кофе добавлен, id - ' || ret;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION createDessert(name text, price float, calories float, weight float) RETURNS TEXT STRICT AS $$
DECLARE
ret int;
BEGIN
	INSERT INTO товар(название, стоимость, вес) VALUES(name, price, weight) RETURNING id INTO ret;
	INSERT INTO десерт(id, товар, калории) VALUES(ret, ret, calories);
	RETURN 'Десерт добавлен, id - ' || ret;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION addCoffeeRating(rating int, comments text, coffee int) RETURNS TEXT STRICT AS $$
DECLARE
ret int;
BEGIN
	INSERT INTO оценка(оценка, отзыв) VALUES(rating, comments) RETURNING id INTO ret;
	INSERT INTO оценка_кофе(id, оценка, кофе) VALUES(ret, ret, coffee);
	RETURN 'Оценка на кофе добавлена, id - ' || ret;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION addScheduleRating(rating int, comments text, schedule int) RETURNS TEXT STRICT AS $$
DECLARE
ret int;
BEGIN
	INSERT INTO оценка(оценка, отзыв) VALUES(rating, comments) RETURNING id INTO ret;
	INSERT INTO оценка_расписания(id, оценка, расписание) VALUES(ret, ret, coffee);
	RETURN 'Оценка на расписание добавлена, id - ' || ret;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION copySchedule(schedule int, client int) RETURNS INT STRICT AS $$
DECLARE
newSchedId int;
BEGIN
INSERT INTO расписание(название, клиент, описание, состояние) SELECT название, client, описание, 'E'  FROM расписание WHERE id =  schedule RETURNING id INTO newSchedId;
	INSERT INTO запись_расписания(название, расписание, заказ, периодичность) SELECT название, newSchedId, заказ, периодичность FROM запись_расписания WHERE расписание = schedule;
	RETURN newSchedId;
END;
$$ LANGUAGE 'plpgsql';
CREATE OR REPLACE FUNCTION copyRecipe(recipe int, client int) RETURNS INT STRICT AS $$
DECLARE
newRecipeId int;
BEGIN
INSERT INTO рецепт(клиент) VALUES (client) RETURNING id INTO newRecipeId;
	INSERT INTO компонент_рецепта(рецепт, ингредиент, количество, порядок_добавления) SELECT newRecipeId, ингридиент, количество, порядок_добавления FROM компонент_рецепта WHERE  рецепт = recipe;
	RETURN newRecipeId;
END;
$$ LANGUAGE 'plpgsql';
