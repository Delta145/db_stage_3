CREATE OR REPLACE FUNCTION calculate_recipe_total_volume(coffee INT) RETURNS float AS
$$
DECLARE
    sum float;
BEGIN
    SELECT SUM(компонент_кофе.количество * ингредиент.количество_мл) as whole_volume
                 FROM компонент_кофе
                          JOIN ингредиент ON компонент_кофе.id_ингредиента = ингредиент.id
                 WHERE компонент_кофе.id_кофе = coffee INTO sum;
    RETURN sum;
END;
$$ LANGUAGE plpgsql;

-- триггер чтобы нельзя если вес ингредиентов больше определённого объёма
CREATE OR REPLACE FUNCTION check_recipe() RETURNS TRIGGER AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF (calculate_recipe_total_volume(NEW.id_кофе) +
            NEW.количество * (SELECT количество_мл FROM ингредиент WHERE id = NEW.id_ингредиента)) > 400 THEN
            RETURN NULL;
        ELSE
            RETURN NEW;
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        IF (calculate_recipe_total_volume(NEW.id_кофе) +
            NEW.количество * (SELECT количество_мл FROM ингредиент WHERE id = NEW.id_ингредиента) -
            OLD.количество * (SELECT количество_мл FROM ингредиент WHERE id = OLD.id_ингредиента)) > 400 THEN
            RETURN NULL;
        ELSE
            RETURN NEW;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER recipe_ingredients
    BEFORE INSERT OR UPDATE
    ON компонент_кофе
    FOR EACH ROW
EXECUTE PROCEDURE check_recipe();


CREATE OR REPLACE FUNCTION delete_score() RETURNS TRIGGER AS
$$
BEGIN
    DELETE FROM оценка WHERE оценка.id = OLD.id_оценки;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
-- триггер удаления оценок при удалении оценки кофе
CREATE TRIGGER score_coffee_delete
    AFTER DELETE
    ON оценка_кофе
    FOR EACH ROW
EXECUTE PROCEDURE delete_score();

-- триггер удаления оценок при удалении оценки расписания
CREATE TRIGGER score_schedule_delete
    AFTER DELETE
    ON оценка_расписания
    FOR EACH ROW
EXECUTE PROCEDURE delete_score();

CREATE OR REPLACE FUNCTION delete_product() RETURNS TRIGGER AS
$$
BEGIN
    DELETE FROM товар WHERE товар.id = OLD.id_товара;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- триггер удаления товара при удалении десерта
CREATE TRIGGER desert_product_delete
    AFTER DELETE
    ON десерт
    FOR EACH ROW
EXECUTE PROCEDURE delete_product();

-- триггер удаления товара при удалении кофе
CREATE TRIGGER coffee_product_delete
    AFTER DELETE
    ON кофе
    FOR EACH ROW
EXECUTE PROCEDURE delete_product();
