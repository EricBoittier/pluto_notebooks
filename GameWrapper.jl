module GameWrapper

using Random
include("Game.jl")
using .Redacted

# Game wrapper functions
mutable struct GameWrapper
    game::Game
end

function Game_Create()
    seed = RandomDevice()()
    return GameWrapper(Game(seed))
end

function Game_Create_Seeded(seed::Int)
    return GameWrapper(Game(seed))
end

function Game_Destroy(wrapper::GameWrapper)
    wrapper.game = nothing  # Clear the reference for garbage collection
end

function AddPlayer(wrapper::GameWrapper, playerName::String)
    turnAction = TurnAction(:AddPlayer, nothing, nothing, Vector{Int}(), nothing, nothing)
    println("playerName: $playerName")
    turnAction.sourcePlayer = wrapper.game.add_player!(playerName)
    turnAction.succeeded = turnAction.sourcePlayer != nothing
    return turnAction
end

function StartGame(wrapper::GameWrapper)
    turnAction = TurnAction(:StartGame, nothing, nothing, Vector{Int}(), nothing, nothing)
    turnAction.succeeded = start_game!(wrapper.game)
    return turnAction
end

function PlayCard(wrapper::GameWrapper, sourcePlayer::Player, sourceCard::Card, targetIndex::Int)
    turnAction = TurnAction(:PlayCard, sourcePlayer, sourceCard, Vector{Int}(), nothing, nothing)
    turnAction.targetIndex = targetIndex
    turnAction.succeeded = perform!(wrapper.game, turnAction)
    return turnAction
end

function ChallengeCard(wrapper::GameWrapper, sourcePlayer::Player, sourceCard::Card, targetPlayer::Player, targetCard::Card)
    turnAction = TurnAction(:ChallengeCard, sourcePlayer, sourceCard, Vector{Int}(), targetCard, targetPlayer)
    turnAction.succeeded = perform!(wrapper.game, turnAction)
    return turnAction
end

function InkCard(wrapper::GameWrapper, sourcePlayer::Player, sourceCard::Card)
    turnAction = TurnAction(:InkCard, sourcePlayer, sourceCard, Vector{Int}(), nothing, nothing)
    turnAction.succeeded = perform!(wrapper.game, turnAction)
    return turnAction
end

function QuestCard(wrapper::GameWrapper, sourcePlayer::Player, sourceCard::Card)
    turnAction = TurnAction(:QuestCard, sourcePlayer, sourceCard, Vector{Int}(), nothing, nothing)
    turnAction.succeeded = perform!(wrapper.game, turnAction)
    return turnAction
end

function Mulligan(wrapper::GameWrapper, sourcePlayer::Player, mulligans::Vector{Int})
    turnAction = TurnAction(:Mulligan, sourcePlayer, nothing, mulligans, nothing, nothing)
    turnAction.succeeded = perform!(wrapper.game, turnAction)
    return turnAction
end

function PassTurn(wrapper::GameWrapper, sourcePlayer::Player)
    turnAction = TurnAction(:PassTurn, sourcePlayer, nothing, Vector{Int}(), nothing, nothing)
    turnAction.succeeded = perform!(wrapper.game, turnAction)
    return turnAction
end

function MoveToLocation(wrapper::GameWrapper, sourcePlayer::Player, sourceCard::Card, targetLocation::Card)
    turnAction = TurnAction(:MoveToLocation, sourcePlayer, sourceCard, Vector{Int}(), targetLocation, nothing)
    turnAction.succeeded = perform!(wrapper.game, turnAction)
    return turnAction
end

end # module GameWrapper