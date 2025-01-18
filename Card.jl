module CardData

using JSON
using Base: push!

# Define Enums
@enum CardType Character Action Item Location Song
CardType_inst = instances(CardType)
CardType_syms = Symbol.(CardType_inst)
CardType_condsym = Dict(zip(CardType_syms, CardType_inst))
println(CardType_condsym)

@enum Classification Inventor Hyena Detective Knight Captain Deity Queen Princess Madrigal Musketeer Sorcerer Seven_Dwarfs Tigger Dragon Pirate Puppy Titan Fairy Broom King Prince Mentor Entangled Ally Villain Hero Alien Dreamborn Storyborn Floodborn 
Classification_inst = instances(Classification)
Classification_syms = Symbol.(Classification_inst)
Classification_condsym = Dict(zip(Classification_syms, Classification_inst))
# println(Classification_condsym)

@enum Rarity Common Uncommon Rare Super_Rare Legendary Enchanted Special
Rarity_inst = instances(Rarity)
Rarity_syms = Symbol.(Rarity_inst)
Rarity_condsym = Dict(zip(Rarity_syms, Rarity_inst))
# println(Rarity_condsym)

@enum CardColor Amber Amethyst Emerald Ruby Sapphire Steel Unknown 
CardColor_inst = instances(CardColor)
CardColor_syms = Symbol.(CardColor_inst)
CardColor_condsym = Dict(zip(CardColor_syms, CardColor_inst))
# println(CardColor_condsym)

# Define the Card struct
mutable struct Card
    cost::Int
    fullName::String
    baseName::String
    version::String
    cardTypes::Vector{CardType}
    classifications::Vector{Classification}
    strength::Int
    willpower::Int
    lore::Int
    inkable::Bool
    abilitiesText::Vector{String}
    rarity::Rarity
    color::CardColor
    atLocation::Bool
    hasRush::Bool
    hasEvasive::Bool
    hasWard::Bool
    hasBodyguard::Bool
    resistValue::Int
    singerValue::Int
    hasShift::Bool
    shiftValue::Int

    function Card(cost::Int, fullName::String, baseName::String, version::String, 
                  cardTypes::Vector{CardType}, classifications::Vector{Classification}, 
                  strength::Int, willpower::Int, lore::Int, inkable::Bool, 
                  abilitiesText::Vector{String}, rarity::Rarity, color::CardColor, atLocation::Bool)
        new(cost, fullName, baseName, version, cardTypes, classifications, strength, 
            willpower, lore, inkable, abilitiesText, rarity, color, atLocation, false, false, 
            false, false, 0, cost, false, 0)
    end
end

# Parse card abilities
function parseCardText(card::Card)
    for abilityText in card.abilitiesText
        if occursin("Rush", abilityText)
            card.hasRush = true
        elseif occursin("Evasive", abilityText)
            card.hasEvasive = true
        elseif occursin("Ward", abilityText)
            card.hasWard = true
        elseif occursin("Bodyguard", abilityText)
            card.hasBodyguard = true
        end

        # Resist +N
        if match == match(r"Resist \+(\d+)", abilityText)
            card.resistValue = parse(Int, match.captures[1])
        end

        # Singer N
        if match == match(r"Singer (\d+)", abilityText)
            card.singerValue = parse(Int, match.captures[1])
        end

        # Shift N
        if match == match(r"Shift (\d+)", abilityText)
            card.hasShift = true
            card.shiftValue = parse(Int, match.captures[1])
        end
    end
end

# Apply damage
function ApplyDamage(card::Card, damageAmount::Int)
    damageAmount -= card.resistValue
    damageAmount = max(0, damageAmount)  # Damage can't be negative
    return damageAmount
end

# Change card zone
function ChangeZone(from::Vector{Card}, to::Vector{Card}, card::Card, index::Int=-1)
    deleteat!(from, findfirst(x -> x === card, from))
    if index < 0
        push!(to, card)
    else
        insert!(to, index + 1, card)
    end
end




# Enum helper functions
function getCardType(typeStr::String)::CardType
    # Convert string to enum
    # doesn't work: return CardType[typeStr]
    return CardType_condsym[Symbol(typeStr)]
end

function getClassification(classStr::String)::Classification
    return Classification_condsym[Symbol(classStr)]
end

function getRarity(rarityStr::String)::Rarity
    return Rarity_condsym[Symbol(replace(rarityStr, 
        " " => "_",))]
end

function getColor(colorStr::String)::CardColor
    return CardColor_condsym[Symbol(colorStr)]
end

# Create a Card from JSON
function Card(jsonValue::Dict{String, Any})
    cost = jsonValue["Cost"]
    fullName = jsonValue["Name"]
    baseName = string(split(fullName, " - ")[1])
    cardType_strings = split(jsonValue["Type"]," - ")
    cardTypes = [getCardType(string(x)) for x in cardType_strings]
    if "Classifications" in keys(jsonValue)
        classifications_strings = split(jsonValue["Classifications"], ", ")
    else
        classifications_strings = []
    end
    classifications = [getClassification(string(c)) for c in classifications_strings]
    strength = get(jsonValue, "Strength", 0)
    willpower = get(jsonValue, "Willpower", 0)
    lore = get(jsonValue, "Lore", 0)
    inkable = jsonValue["Inkable"]
    if "Abilities" in keys(jsonValue)
        abilitiesText = [jsonValue["Abilities"]]
    else
        abilitiesText = [""]
    end
    rarity = getRarity(jsonValue["Rarity"])
    color = getColor(jsonValue["Color"])
    atLocation = false
    version = get(jsonValue, "Version", "")
    card = Card(cost, fullName, baseName, version, cardTypes, classifications, strength, 
                willpower, lore, inkable, abilitiesText, rarity, color, atLocation)

    parseCardText(card)
    return card
end

end 