# SQL završni rad (Marko Ilić)

- Završni test ima 4 cjeline:

    + A: 10 pitanja o podacima

    + B: izvještaj o sezoni
        
        - Sastoji se od dva dijela, ***part_B_queries.sql*** sadrži upite,
          dok ***season_report.md*** prikazuje izvještaj o sezoni.

    + C: 5 pitanja sa prozorskim funkcijama

    + D: Model za analizu discipline (zvjezdasta shema):

        - Nova tabela ***fact_card*** sadrži redove koji čuvaju informacije o svim kartonima
          dodjeljenih u toku obje sezone. Ona se sastoji od sljedećih kolona:
    
            + event_id
            + match_id 
            + date_key 
            + team_id
            + player_id 
            + referee_id
            + card_type
        
        - Povezana je preko stranih ključeva: `team_id` sa `dim_team`, `player_id` sa `dim_player`, `referee_id` sa `dim_referee` i `date_key` sa    `dim_date`.

        - Ova tabela omogućava jasan prikaz informacija po dodjeljenom kartonu, tako da brzo i efikasno možemo vidjeti podatke o sudijama, igračima,
        klubu vremenu, kao i o vrsti kartona.
