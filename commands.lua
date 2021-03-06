local GetChatName = logicHandler.GetChatName

local function ERROR(pid, message)
    tes3mp.SendMessage(pid, color.Red .. message .. "\n")
end

local function test(condition, pid, message)
    if not condition then
        ERROR(pid, message)
        return false
    end
    return true
end

local function create(pid, name)
    local partyId = PartySystem.getPartyId(pid)
    if test(partyId == nil, pid, "You're already in a party.") then
        partyId = PartySystem.createParty(pid)
        if test(partyId ~= nil, pid, "Unable to create party") and name ~= nil then
            local party = PartySystem.data.parties[partyId]
            party.name = name
        end
    end
end

local function invite(pid, other)
    local partyId = PartySystem.getPartyId(pid)
    if test(partyId ~= nil, pid, "You're not in a party.") and
        test(other ~= nil, pid, "Expected the pid of the person you want to invite.") then
        other = tonumber(other)
        PartySystem.inviteMember(partyId, other, GetChatName(pid))
        tes3mp.SendMessage(pid, color.Default .. "Invite sent.\n")
    end
end

local function accept(pid, other)
    other = tonumber(other)
    local partyId = PartySystem.getPartyId(other)
    if test(partyId ~= nil and PartySystem.isInvited(partyId, pid), pid, "You're not invited to the party.") then
        PartySystem.acceptInvite(partyId, pid)
    end
end

local function uninvite(pid, other)
    local partyId = PartySystem.getPartyId(pid)
    if test(partyId ~= nil, pid, "You're not in a party.") and
        test(other ~= nil, pid, "Expected the pid of the person you want to uninvite.") and
        test(PartySystem.isPartyLeader(partyId, pid), pid, "Only the leader can uninvite.") then
        other = tonumber(other)
        PartySystem.removeInvite(partyId, other)
        tes3mp.SendMessage(pid, color.Default .. "Invite rescinded.\n")
    end
end

local function kick(pid, other)
    local partyId = PartySystem.getPartyId(pid)
    if test(partyId ~= nil, pid, "You're not in a party.") and
        test(other ~= nil, pid, "Expected the pid of the person you want to kick.") and
        test(PartySystem.isPartyLeader(partyId, pid), pid, "Only the leader can kick.") then
        other = tonumber(other)
        PartySystem.removeMember(partyId, other)
    end
end

local function leave(pid)
    local partyId = PartySystem.getPartyId(pid)
    if test(partyId ~= nil, pid, "You're not in a party.") then
        PartySystem.removeMember(partyId, pid)
    end
end

local function mainCommand(pid, cmd)

    if cmd[2] == "create" or cmd[2] == "c" then
        create(pid, cmd[3])
    elseif cmd[2] == "invite" or cmd[2] == "i" then
        invite(pid, cmd[3])
    elseif cmd[2] == "accept" or cmd[2] == "a" then
        accept(pid, cmd[3])
    elseif cmd[2] == "uninvite" or cmd[2] == "u" then
        uninvite(pid, cmd[3])
    elseif cmd[2] == "kick" or cmd[2] == "k" then
        kick(pid, cmd[3])
    elseif cmd[2] == "leave" or cmd[2] == "l" then
        leave(pid)
    else
        tes3mp.SendMessage(pid, 
            color.GreenText 
            .. "/party create(or c) [party_name] - Create a party of [party_name].\n"
            .. "/party invite(or i) [pid] - Invite a player with a player id of [pid].\n"
            .. "/party accept(or a) [party_name] - Accept a party invite to a party named [party_name].\n"
            .. "/party uninvite(or u) [pid] - Uninvite a player with a player id of [pid] from the party.\n"
            .. "/party kick(or k) [pid] - Kick a player with a player id of [pid] from the party.\n"
            .. "/party leave(or l) - Leave your current party.\n"
        )
    end

end

customCommandHooks.registerCommand("party", mainCommand)
