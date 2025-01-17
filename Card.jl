module Redacted

using JSON
using Base: push!

# Define Enums (using Julia's approach)
enum CardType Character Action Item Location end
enum Classification Inventor Hyena Detective Knight Captain Song Deity Queen Princess Madrigal Musketeer Sorcerer Seven_Dwarfs Tigger Dragon Pirate Puppy Titan Fairy Broom King Prince Mentor Entangled Ally Villain Hero Alien Dreamborn Storyborn Floodborn end
enum Rarity Common Uncommon Rare Super_Rare Legendary Enchanted Special end
enum CardColor Amber Amethyst Emerald Ruby Sapphire Steel Unknown end

# Define the Card struct
mutable struct Card
    cost::Int
    fullName::String
    baseName::String
    version::String
    cardType::CardType
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
                  cardType::CardType, classifications::Vector{Classification}, 
                  strength::Int, willpower::Int, lore::Int, inkable::Bool, 
                  abilitiesText::Vector{String}, rarity::Rarity, color::CardColor, atLocation::Bool)
        new(cost, fullName, baseName, version, cardType, classifications, strength, 
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
        if match = match(r"Resist \+(\d+)", abilityText)
            card.resistValue = parse(Int, match.captures[1])
        end

        # Singer N
        if match = match(r"Singer (\d+)", abilityText)
            card.singerValue = parse(Int, match.captures[1])
        end

        # Shift N
        if match = match(r"Shift (\d+)", abilityText)
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
    return CardType[typeStr]
end

function getClassification(classStr::String)::Classification
    return Classification[classStr]
end

function getRarity(rarityStr::String)::Rarity
    return Rarity[rarityStr]
end

function getColor(colorStr::String)::CardColor
    return CardColor[colorStr]
end

# Create a Card from JSON
function Card(jsonValue::Dict{String, Any})
    cost = jsonValue["cost"]
    fullName = jsonValue["fullName"]
    baseName = jsonValue["baseName"]
    version = jsonValue["subtitle"]
    cardType = getCardType(jsonValue["type"])

    classifications = [getClassification(c) for c in jsonValue["subtypes"]]
    strength = get(jsonValue, "strength", 0)
    willpower = get(jsonValue, "willpower", 0)
    lore = get(jsonValue, "lore", 0)
    inkable = jsonValue["inkwell"]
    abilitiesText = [ability for ability in jsonValue["abilities"]]
    rarity = getRarity(jsonValue["rarity"])
    color = getColor(jsonValue["color"])
    atLocation = false

    card = Card(cost, fullName, baseName, version, cardType, classifications, strength, 
                willpower, lore, inkable, abilitiesText, rarity, color, atLocation)

    parseCardText(card)
    return card
end

end # module Redacted