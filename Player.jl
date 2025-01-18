module PlayerState

include("Card.jl")
using .CardData
import .CardData.Card as Card



mutable struct Player
    id::Int
    name::String
    field::Vector{Card}
    inkwell::Vector{Card}
    deck::Vector{Card}
    hand::Vector{Card}
    loreTotal::Int
    inkedThisTurn::Bool

    function Player(name::String, id::Int64, deck::Vector{Card})
        new(id, name, Card[], Card[], deck, Card[], 0, false)
    end

    function DoTurnStart!(player::Player, doDraw::Bool=true)
        for card in player.field
            DoReadyPhase!(card)
        end

        for card in player.inkwell
            DoReadyPhase!(card)
        end

        for card in player.field
            DoSetPhase!(card, player)
        end

        player.inkedThisTurn = false

        if doDraw
            push!(player.hand, pop!(player.deck))
        end

        return true
    end

    function DoTurnEnd!(player::Player)
        for card in player.field
            card.canQuestThisTurn = true
        end
        return true
    end

    function CanPlay(player::Player, card::Card)
        readyInk = filter(c -> c.isReady, player.inkwell)

        if card.hasShift && card.shiftValue <= length(readyInk)
            shiftTargets = filter(c -> c.baseName == card.baseName, player.field)
            return !isempty(shiftTargets)
        end

        return card.cost <= length(readyInk)
    end

    function CanInk(player::Player, card::Card)
        return !player.inkedThisTurn && card.inkable
    end

    function CanMove(player::Player, character::Card, location::Card)
        readyInk = filter(c -> c.isReady, player.inkwell)
        return location.strength <= length(readyInk)
    end

    function DoReadyPhase!(card::Card)
        if card.canReadyThisTurn
            card.isReady = true
        end
        return true
    end

    function DoSetPhase!(card::Card, player::Player)
        card.isDry = true
        if card.cardType == :Location
            player.loreTotal += card.lore
        end
        card.canReadyThisTurn = true
        return true
    end

    function DrawCards!(player::Player, numCards::Int=1)
        for _ in 1:numCards
            if isempty(player.deck)
                return false
            end
            push!(player.hand, pop!(player.deck))
        end
        return true
    end
end

end # module Player