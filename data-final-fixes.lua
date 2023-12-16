local arc_util = require("arch_util")

-- Generate smelting recipes
for _, recipe in pairs(data.raw.recipe) do
    if recipe.category == "kiln" or recipe.category == "smelting" then
        if recipe.name and recipe.name ~= "" and arc_util.verify_results(recipe) and not data.raw.recipe["arc-"..recipe["name"]] then
            log("Generating Arc Furnace recipe for "..recipe.name)
            arc_util.generate_arc_smelting_recipe(recipe)
        end
    end
end
