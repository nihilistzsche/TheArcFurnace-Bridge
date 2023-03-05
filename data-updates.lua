local function copy_recipe_data(src, dst, scale)
    -- does this recipe have "normal" or "expensive" variants?
    -- If so, the recipe data is actually in those tables.
    -- (... if they are tables - they can be false if the recipe is to be disabled in that mode).
    if src["normal"] ~= nil or src["expensive"] ~= nil then
        if type(src["normal"]) == "table" then
            dst["normal"] = {}
            copy_recipe_data(src["normal"], dst["normal"], scale)
        else
            dst["normal"] = src["normal"]
        end
    
        if type(src["expensive"]) == "table" then
            dst["expensive"] = {}
            copy_recipe_data(src["expensive"], dst["expensive"], scale)
        else
            dst["expensive"] = src["expensive"]
        end
    else
        dst["ingredients"] = {}
        for idx, ispec in pairs(src["ingredients"]) do
            -- Ingredient prototypes exist in two flavours: array-like and map-like.
            if #ispec > 1 then
                dst["ingredients"][idx] = {
                    ispec[1],
                    ispec[2] * scale
                }
            else
                dst["ingredients"][idx] = {
                    ["type"] = ispec["type"],
                    ["name"] = ispec["name"],
                    ["amount"] = ispec["amount"] * scale,
                    ["catalyst_amount"] = (ispec["catalyst_amount"] or 0) * scale,
                    ["temperture"] = ispec["temperature"],
                    ["minimum_temperture"] = ispec["minimum_temperature"],
                    ["maximum_temperture"] = ispec["maximum_temperature"],
                    ["fluidbox_index"] = ispec["fluidbox_index"]
                }
            end
        end

        dst["energy_required"] = src["energy_required"]

        if src["result"] ~= nil then
            dst["result"] = src["result"]
            dst["result_count"] = (src["result_count"] or 1) * scale
        end

        if src["results"] ~= nil then
            dst["results"] = {}
            for idx, rspec in pairs(src["results"]) do
                dst["results"][idx] = {
                    ["type"] = rspec["type"],
                    ["name"] = rspec["name"],
                    ["amount"] = (rspec["amount"] or 0) * scale,
					["amount_min"] = (rspec["amount_min"] or 0) * scale,
					["amount_max"] = (rspec["amount_max"] or 0) * scale,
                    ["temperture"] = rspec["temperature"]
                }
            end
        end
    end
end


local function mimic_recipe_module_limitations(source_recipe, target_recipe)
    for _, module in pairs(data.raw["module"]) do
        if module.limitation ~= nil then
            for _, recipe in ipairs(module.limitation) do
                if recipe == source_recipe then
                    table.insert(module.limitation, target_recipe)
                    break
                end
            end
        end

        if module.limitation_blacklist ~= nil then
            for _, recipe in ipairs(module.limitation_blacklist) do
                if recipe == source_recipe then
                    table.insert(module.limitation_blacklist, target_recipe)
                    break
                end
            end
        end
    end
end


local function generate_arc_smelting_recipe(original_recipe)
    if original_recipe["category"] ~= "kiln" then
        return
    end

    recipe = {
        ["type"] = "recipe",
        ["name"] = "arc-" .. original_recipe["name"],
        ["category"] = "arc-smelting",
    }

    copy_recipe_data(original_recipe, recipe, 10)
    data:extend({recipe})
    mimic_recipe_module_limitations(original_recipe["name"], recipe["name"])
end


-- Generate smelting recipes
for _, recipe in pairs(data.raw["recipe"]) do
    if recipe["category"] == "kiln" then
        generate_arc_smelting_recipe(recipe)
    end
end
