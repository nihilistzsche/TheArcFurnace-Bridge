local arc_util = {}

local max_amt = 65535
function arc_util.update_amounts(dst, scale)
    for idx, ispec in pairs(dst.ingredients) do
        if #ispec > 1 then
            local i = dst.ingredients[idx]
            i[2] = math.min(i[2] * scale, max_amt)
        else
            local i = dst.ingredients[idx]
            i.amount = math.min(i.amount * scale, max_amt)
            if i.catalyst_amount then
                i.cataclyst_amount = math.min(i.catalyst_amount * scale, max_amt)
            end
        end
    end
    if dst.result and dst.result_count then
        dst.result_count = math.min(dst.result_count * scale, max_amt)
    end
    if dst.results then
        for idx, rspec in pairs(dst.results) do
            local i = dst.results[idx]
            function arc_util.upd(key)
                if i[key] then
                    i[key] = math.min(i[key] * scale, max_amt)
                end
            end
            upd("amount")
            upd("amount_min")
            upd("amount_max")
        end
    end
end
            
function arc_util.copy_recipe_data(src, scale)
    local dst = util.table.deepcopy(src)
    if dst.normal or expensive then
        if dst.normal then
            arc_util.update_amounts(dst.normal, scale)
        end
        if dst.expensive then
            arc_util.update_amounts(dst.expensive, scale)
        end
    else
        arc_util.update_amounts(dst, scale)
    end
    dst.name = "arc-"..src.name
    dst.category = "arc-smelting"
    return dst
end


function arc_util.mimic_recipe_module_limitations(source_recipe, target_recipe)
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


function arc_util.generate_arc_smelting_recipe(original_recipe)
    data:extend({arc_util.copy_recipe_data(original_recipe, 10)})
    arc_util.mimic_recipe_module_limitations(original_recipe.name, recipe.name)
end

function arc_util.verify_results(recipe)
    local passed = false
    if recipe.normal or recipe.expensive then
        if recipe.normal then
            passed = (recipe.normal.result or recipe.normal.results) ~= nil
        end
        if recipe.expensive and not passed then
            passed = (recipe.expensive.result or recipe.expensive.results) ~= nil
        end
    end 
    if recipe.result and not passed then
        passed = recipe.result and recipe.result.name ~= nil
    end
    if recipe.results and not passed then
        passed = recipe.results[1] and recipe.results[1].name ~= nil
    end
    return passed
end

return arc_util
