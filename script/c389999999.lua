--Custom rule: Second player draws 6 and skips first draw phase
local s, id = GetID()

function s.initial_effect(c)
  --Activate at duel start
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
  e1:SetCode(EVENT_STARTUP)
  e1:SetOperation(s.startup)
  Duel.RegisterEffect(e1, 0)
end

function s.startup(e, tp, eg, ep, ev, re, r, rp)
  --Run only once
  if Duel.GetFlagEffect(0, id) ~= 0 then
    return
  end
  Duel.RegisterFlagEffect(0, id, 0, 0, 1)

  --Determine second player
  local p2 = 1 - Duel.GetTurnPlayer()

  --Give second player +1 card (to make 6 total)
  Duel.Draw(p2, Duel.GetDrawCount(p2), REASON_RULE)

  --Create effect to skip first draw phase
  local e1 = Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_SKIP_DP)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetTargetRange(1, 0)
  e1:SetTarget(function(e, c)
    return c == p2
  end)
  e1:SetReset(RESET_PHASE + PHASE_DRAW + RESET_SELF_TURN)
  Duel.RegisterEffect(e1, p2)
end
