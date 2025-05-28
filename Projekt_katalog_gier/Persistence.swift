import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Projekt_katalog_gier")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        
        preloadDataIfNeeded(context: container.viewContext)
    }

    // Sprawdzenie czy w bazie są dane, jeśli nie - wywołuje załadowanie danych startowych
    private func preloadDataIfNeeded(context: NSManagedObjectContext) {
        let request: NSFetchRequest<Game> = Game.fetchRequest() //zapytanie do bazy o obiekty Game

        do {
            let count = try context.count(for: request)
            if count == 0 {
                preloadInitialData(context: context)
            }
        } catch {
            print("Błąd przy sprawdzaniu danych początkowych: \(error)")
        }
    }
    
    // Funkcja dodająca początkowe dane do bazy
    private func preloadInitialData(context: NSManagedObjectContext) {
        
        // DODANIE NAZW GATUNKÓW
        let genreNames = [
            "RPG", "Action", "Adventure", "Shooter", "Strategy", "Simulation",
            "Platformer", "Puzzle", "Horror", "Sports", "Racing", "Fighting",
            "Stealth", "Survival", "MMO", "Sandbox", "Indie", "Battle Royale",
            "Open World", "Fantasy", "Sci-Fi", "Historical", "Multiplayer",
            "Singleplayer", "Tactical", "MOBA"
        ]

        var genresDict: [String: Genre] = [:]

        // Tworzenie obiektów gatunków i zapisywanie ich w słowniku
        for name in genreNames {
            let genre = Genre(context: context)
            genre.name = name
            genre.id = UUID()
            genresDict[name] = genre
        }

        // Pomocnicza funkcja do dodawania pojedynczej gry
        func addGame(title: String, rating: Double, releaseDate: Date, publisher: String, genreNames: [String], coverImageName: String? = nil, isCustom: Bool = false, descriptionText: String) {
            let game = Game(context: context)
            game.title = title
            game.rating = rating
            game.releaseDate = releaseDate
            game.publisher = publisher
            game.isFavorite = false
            game.isCompleted = false
            game.isCustom = isCustom
            game.id = UUID()
            game.coverImageName = coverImageName
            game.toGenre = NSSet(array: genreNames.compactMap { genresDict[$0] }) //połączenie gry z gatunkiem
            game.descriptionText = descriptionText
        }
        
        //DODANIE GIER
        addGame(title: "The Witcher 3: Wild Hunt", rating: 9.8, releaseDate: Date(timeIntervalSince1970: 1431993600), publisher: "CD Projekt", genreNames: ["RPG", "Open World", "Fantasy"], coverImageName: "witcher3_cover", descriptionText: "Jako wiedźmin Geralt z Rivii, gracz przemierza mroczny świat fantasy, poszukując swojej zaginionej córki. Gra oferuje otwarty świat, bogaty w decyzje moralne i angażującą fabułę.")
        addGame(title: "Cyberpunk 2077", rating: 8.5, releaseDate: Date(timeIntervalSince1970: 1607558400), publisher: "CD Projekt", genreNames: ["RPG", "Open World", "Sci-Fi"], coverImageName: "cyberpunk2077_cover", descriptionText: "Osadzona w dystopijnym Night City gra pozwala na wcielenie się w V, najemnika z możliwością pełnej personalizacji. Gracze mogą wybierać spośród różnych stylów gry, takich jak hakowanie, walka wręcz czy strzelanie.")
        addGame(title: "God of War", rating: 9.6, releaseDate: Date(timeIntervalSince1970: 1524182400), publisher: "Sony Interactive Entertainment", genreNames: ["Action", "Adventure", "Fantasy"], coverImageName: "godofwar_cover", descriptionText: "Kontynuacja serii, która przenosi Kratosa do świata nordyckiej mitologii. Gra łączy elementy akcji z głęboką narracją, skupiając się na relacji ojca z synem.")
        addGame(title: "Red Dead Redemption 2", rating: 9.7, releaseDate: Date(timeIntervalSince1970: 1540512000), publisher: "Rockstar Games", genreNames: ["Action", "Adventure", "Open World", "Historical"], coverImageName: "rdr2_cover", descriptionText: "Przedstawia losy Arthura Morgana, członka gangu Van der Linde, w schyłkowym okresie Dzikiego Zachodu. Gra oferuje otwarty świat, pełen interakcji i moralnych dylematów.")
        addGame(title: "The Legend of Zelda: Breath of the Wild", rating: 9.9, releaseDate: Date(timeIntervalSince1970: 1488499200), publisher: "Nintendo", genreNames: ["Action", "Adventure", "Open World", "Fantasy"], coverImageName: "zelda_botw_cover", descriptionText: "Link budzi się po długim śnie, by ocalić Hyrule przed zagładą. Gra oferuje nieliniową rozgrywkę w otwartym świecie, z elementami przetrwania i eksploracji.")
        addGame(title: "Dark Souls III", rating: 9.2, releaseDate: Date(timeIntervalSince1970: 1460419200), publisher: "Bandai Namco Entertainment", genreNames: ["RPG", "Action", "Fantasy"], coverImageName: "darksoulsIII_cover", descriptionText: "Trzecia odsłona kultowej serii, która kontynuuje opowieść o cyklu ognia i ciemności. Gra charakteryzuje się wysokim poziomem trudności i głęboką fabułą.")
        addGame(title: "Minecraft", rating: 9.0, releaseDate: Date(timeIntervalSince1970: 1271376000), publisher: "Mojang Studios", genreNames: ["Sandbox", "Survival", "Indie"], coverImageName: "minecraft_cover", descriptionText: "Sandboxowa gra, w której gracze mogą budować, eksplorować i przetrwać w proceduralnie generowanym świecie. Popularna zarówno wśród młodszych, jak i starszych graczy.")
        addGame(title: "Overwatch", rating: 8.7, releaseDate: Date(timeIntervalSince1970: 1464134400), publisher: "Blizzard Entertainment", genreNames: ["Shooter", "Multiplayer"], coverImageName: "overwatch_cover", descriptionText: "Drużynowa strzelanka, w której gracze wcielają się w unikalnych bohaterów, każdy z własnymi zdolnościami. Gra kładzie duży nacisk na współpracę i strategię drużynową.")
        addGame(title: "Fortnite", rating: 7.5, releaseDate: Date(timeIntervalSince1970: 1506384000), publisher: "Epic Games", genreNames: ["Battle Royale", "Shooter", "Multiplayer"], coverImageName: "fortnite_cover", descriptionText: "Gra typu battle royale, w której 100 graczy walczy o przetrwanie na coraz mniejszej mapie. Charakteryzuje się dynamiczną akcją i częstymi aktualizacjami.")
        addGame(title: "Doom Eternal", rating: 9.2, releaseDate: Date(timeIntervalSince1970: 1584576000), publisher: "id Software", genreNames: ["Shooter", "Action"], coverImageName: "doometernal_cover", descriptionText: "Kontynuacja rebootu Doom z 2016 roku, oferująca intensywną akcję i walkę z demonami. Gra skupia się na szybkim tempie i brutalnych starciach.")
        addGame(title: "Hades", rating: 9.4, releaseDate: Date(timeIntervalSince1970: 1600300800), publisher: "Supergiant Games", genreNames: ["Action", "Indie", "RPG"], coverImageName: "hades_cover", descriptionText: "Roguelike, w którym gracz wciela się w Zagreusa, syna Hadesa, próbującego uciec z podziemi. Gra łączy dynamiczną akcję z głęboką narracją.")
        addGame(title: "Animal Crossing: New Horizons", rating: 9.1, releaseDate: Date(timeIntervalSince1970: 1584662400), publisher: "Nintendo", genreNames: ["Simulation", "Sandbox"], coverImageName: "animalcrossing_cover", descriptionText: "Symulator życia, w którym gracze budują i rozwijają swoją wyspę, nawiązując relacje z antropomorficznymi zwierzętami. Gra oferuje relaksującą i nieliniową rozgrywkę.")
        addGame(title: "Ghost of Tsushima", rating: 9.3, releaseDate: Date(timeIntervalSince1970: 1594857600), publisher: "Sucker Punch Productions", genreNames: ["Action", "Adventure", "Open World"], coverImageName: "ghostoftsushima_cover", descriptionText: "Akcja gry toczy się w 1274 roku na wyspie Tsushima, gdzie gracz wciela się w samuraja Jin Sakai, broniącego ojczyzny przed najazdem Mongołów. Gra łączy elementy akcji z otwartym światem.")
        addGame(title: "Assassin's Creed Valhalla", rating: 8.3, releaseDate: Date(timeIntervalSince1970: 1604966400), publisher: "Ubisoft", genreNames: ["Action", "Adventure", "Open World", "Historical"], coverImageName: "assassinscreedvalhalla_cover", descriptionText: "Gracz wciela się w Eivora, wikinga, który osiedla się w Anglii, by zbudować nowy dom dla swojego ludu. Gra łączy elementy akcji z otwartym światem i RPG.")
        addGame(title: "Among Us", rating: 8.0, releaseDate: Date(timeIntervalSince1970: 1529020800), publisher: "InnerSloth", genreNames: ["Multiplayer", "Indie"], coverImageName: "amongus_cover", descriptionText: "Gra wieloosobowa, w której gracze współpracują na statku kosmicznym, jednocześnie próbując odkryć, kto spośród nich jest sabotażystą.")
        addGame(title: "Call of Duty: Modern Warfare", rating: 8.4, releaseDate: Date(timeIntervalSince1970: 1571961600), publisher: "Activision", genreNames: ["Shooter", "Action", "Multiplayer"], coverImageName: "callofduty_cover", descriptionText: "Reboot klasycznej serii, oferujący realistyczną kampanię i intensywną rozgrywkę wieloosobową. Gra skupia się na współczesnych konfliktach zbrojnych.")
        addGame(title: "GTA V", rating: 9.5, releaseDate: Date(timeIntervalSince1970: 1376342400), publisher: "Rockstar Games", genreNames: ["Action", "Adventure", "Open World"], coverImageName: "gtav_cover", descriptionText: "Gra akcji osadzona w fikcyjnym mieście Los Santos, gdzie gracz wciela się w trzech przestępców, realizujących różne misje.")
        addGame(title: "League of Legends", rating: 8.6, releaseDate: Date(timeIntervalSince1970: 1251763200), publisher: "Riot Games", genreNames: ["MOBA", "Multiplayer"], coverImageName: "leagueoflegends_cover", descriptionText: "Drużynowa gra MOBA, w której dwie drużyny po pięciu graczy rywalizują ze sobą na specjalnie zaprojektowanej mapie.")
        addGame(title: "Valorant", rating: 8.2, releaseDate: Date(timeIntervalSince1970: 1591056000), publisher: "Riot Games", genreNames: ["Shooter", "Multiplayer"], coverImageName: "valorant_cover", descriptionText: "Taktyczna strzelanka, łącząca elementy strzelania z unikalnymi zdolnościami postaci. Gra kładzie duży nacisk na współpracę drużynową.")
        addGame(title: "The Elder Scrolls V: Skyrim", rating: 9.4, releaseDate: Date(timeIntervalSince1970: 1320883200), publisher: "Bethesda", genreNames: ["RPG", "Open World", "Fantasy"], coverImageName: "tesvskyrim_cover", descriptionText: "Otwarte RPG, w którym gracz wciela się w Dovahkiina, bohatera zdolnego do używania smoczych mocy. Gra oferuje ogromny świat do eksploracji.")
        addGame(title: "Fall Guys", rating: 7.8, releaseDate: Date(timeIntervalSince1970: 1596585600), publisher: "Mediatonic", genreNames: ["Multiplayer", "Platformer"], coverImageName: "fallguys_cover", descriptionText: "Gra typu battle royale, w której gracze rywalizują w serii zabawnych i chaotycznych mini-gier.")
        addGame(title: "Cuphead", rating: 8.9, releaseDate: Date(timeIntervalSince1970: 1506729600), publisher: "StudioMDHR", genreNames: ["Platformer", "Indie"], coverImageName: "cuphead_cover", descriptionText: "Platformówka inspirowana animacjami z lat 30., w której gracze walczą z kreatywnymi bossami w wymagającej rozgrywce.")
        addGame(title: "Minecraft Dungeons", rating: 7.9, releaseDate: Date(timeIntervalSince1970: 1590364800), publisher: "Mojang Studios", genreNames: ["Action", "RPG", "Indie"], coverImageName: "minecraftdungeons_cover", descriptionText: "Spin-off Minecraft, łączący elementy hack and slash z klasycznym światem Minecraft.")
        addGame(title: "Sekiro: Shadows Die Twice", rating: 9.3, releaseDate: Date(timeIntervalSince1970: 1553212800), publisher: "FromSoftware", genreNames: ["Action", "Adventure", "Fantasy"], coverImageName: "sekirosdt_cover", descriptionText: "Gra akcji, w której gracz wciela się w shinobi, walczącego o uratowanie swojego pana w feudalnej Japonii.")
        addGame(title: "Super Mario Odyssey", rating: 9.7, releaseDate: Date(timeIntervalSince1970: 1509062400), publisher: "Nintendo", genreNames: ["Platformer", "Adventure"], coverImageName: "supermarioodyssey_cover", descriptionText: "Platformówka, w której Mario podróżuje po różnych krainach, by uratować księżniczkę Peach.")
        addGame(title: "Rainbow Six Siege", rating: 8.5, releaseDate: Date(timeIntervalSince1970: 1449187200), publisher: "Ubisoft", genreNames: ["Shooter", "Multiplayer", "Tactical"], coverImageName: "rainbowsixsiege_cover", descriptionText: "Taktyczna strzelanka, w której drużyny specjalistów antyterrorystycznych rywalizują w zamkniętych lokacjach.")
        addGame(title: "Metal Gear Solid V", rating: 9.1, releaseDate: Date(timeIntervalSince1970: 1441065600), publisher: "Konami", genreNames: ["Action", "Stealth"], coverImageName: "metalgearsolidv_cover", descriptionText: "Gra akcji, w której gracz wciela się w Big Bossa, walczącego z prywatnymi armiami w otwartym świecie.")
        addGame(title: "Destiny 2", rating: 8.3, releaseDate: Date(timeIntervalSince1970: 1504656000), publisher: "Bungie", genreNames: ["Shooter", "Multiplayer", "Sci-Fi"], coverImageName: "destiny2_cover", descriptionText: "Strzelanka online, łącząca elementy RPG z kooperacyjną rozgrywką. Gracze wcielają się w Strażników, broniących ludzkości przed zagrożeniami.")
        addGame(title: "The Last of Us Part II", rating: 9.6, releaseDate: Date(timeIntervalSince1970: 1592524800), publisher: "Sony Interactive Entertainment", genreNames: ["Action", "Adventure", "Horror"], coverImageName: "thelastofuspartII_cover", descriptionText: "Kontynuacja historii Ellie, młodej kobiety walczącej o przetrwanie w post-apokaliptycznym świecie.")
        addGame(title: "Star Wars Jedi: Fallen Order", rating: 8.4, releaseDate: Date(timeIntervalSince1970: 1573776000), publisher: "Respawn Entertainment", genreNames: ["Action", "Adventure", "Sci-Fi"], coverImageName: "starwarsjedifallenorder_cover", descriptionText: "Wciel się w Cala Kestisa, młodego Jedi ukrywającego się przed Imperium po rozkazie 66. Przemierzaj galaktykę, rozwijaj umiejętności Mocy i walcz z Inkwizytorami, próbując odbudować Zakon Jedi.")
        addGame(title: "Hollow Knight", rating: 9.0, releaseDate: Date(timeIntervalSince1970: 1490572800), publisher: "Team Cherry", genreNames: ["Platformer", "Indie", "Adventure"], coverImageName: "hollowknight_cover", descriptionText: "Eksploruj tajemnicze królestwo Hallownest jako bezimienny rycerz. Pokonuj przeciwników, odkrywaj ukryte sekrety i rozwijaj swoje zdolności w tej ręcznie rysowanej grze akcji typu Metroidvania.")

        // Próba zapisu zmian w kontekście
        do {
            try context.save()
            print("Dane początkowe gier i kategorii zapisane pomyślnie.")
        } catch {
            print("Błąd przy zapisie danych początkowych: \(error)")
        }
    }
}
