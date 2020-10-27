CREATE OR REPLACE FUNCTION calculate_recipe_total_volume(recipe INT) RETURNS SETOF record AS
$$
BEGIN
    RETURN QUERY SELECT SUM(компонент_рецепта.количество * ингредиент.количество_мл) as whole_volume
                 FROM компонент_рецепта
                          JOIN ингредиент ON компонент_рецепта.ингредиент = ингредиент.id
                 WHERE компонент_рецепта.рецепт = recipe;
END;
$$ LANGUAGE plpgsql;
end;

-- триггер чтобы нельзя если вес ингредиентов больше определённого объёма
CREATE OR REPLACE FUNCTION check_recipe() RETURNS TRIGGER AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT количество_мл FROM ингредиент WHERE id = NEW.ингредиент;
        IF (calculate_recipe_total_volume(NEW.рецепт) +
            NEW.количество * (SELECT количество_мл FROM ингредиент WHERE id = NEW.ингредиент)) > 400 THEN
            RETURN NULL;
        ELSE
            RETURN NEW;
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        IF (calculate_recipe_total_volume(NEW.рецепт) +
            NEW.количество * (SELECT количество_мл FROM ингредиент WHERE id = NEW.ингредиент) -
            OLD.количество * (SELECT количество_мл FROM ингредиент WHERE id = OLD.ингредиент)) > 400 THEN
            RETURN NULL;
        ELSE
            RETURN NEW;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER recipe_ingredients
    BEFORE INSERT OR UPDATE
    ON компонент_рецепта
    FOR EACH ROW
EXECUTE PROCEDURE check_recipe();
