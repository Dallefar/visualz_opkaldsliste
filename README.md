# Exports

### Export til at tilføje opkald fra spiller
Denne export er kun tilgængelig fra server
```lua
-- source: Spillerens source
-- message: Besked der skal vises
-- job: Det job beskeden skal sendes til
exports['visualz_opkaldsliste']:AddCall(source, message, job)

-- Eksempel
RegisterCommand('opkald', function(source, args, rawCommand)
    local message = table.concat(args, ' ')
    exports['visualz_opkaldsliste']:AddCall(source, message, 'police')
end, false)
```


### Export til at sende opkald uden spillers source
Denne export er kun tilgængelig fra server
```lua
-- source: nil
-- message: Besked der skal vises
-- job: Det job beskeden skal sendes til
-- coords: Koordinaterne hvor opkaldet er
exports['visualz_opkaldsliste']:AddCall(nil, message, job, coords)
```

# Dallefar

Dette er mit forsøg på at oversætte opkaldslisten til Vrp Framework'et. Jeg kan ikke love, at scriptet er fejlfrit, da det er et stykke tid siden, jeg lavede det.