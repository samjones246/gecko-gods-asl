state("GeckoGods") {}

startup {
    vars.RiverChallenges = new List<string> {
        "4012dc95-6192-4193-ad6d-e354ed710735",
        "734cdc71-2c2c-41f8-acaa-beab07cf235b",
        "d9768cf0-3b8b-4810-ba32-79d918b5acbc",
        "f4cbf4d6-cd7c-4e01-a4c3-2cf55198c24a"
    };
    vars.DesertChallenges = new List<string> {
        "4b2ef8a8-eab3-4e0a-a07e-b45a6f928f5b",
        "119af4a7-7b12-4775-950f-8781c93af63d",
        "8330f88c-db95-413c-8cbb-22551b450e41",
        "afce6488-3f0e-4c27-bd57-583bf1f4098b"
    };
    vars.VolcanoChallenges = new List<string> {
        "2bd60cea-2a15-48a5-a155-615741586635",
        "3f6facf5-0753-4518-9996-c91b5eef0c08",
        "1bfaa080-66ca-457a-a17f-d779a6b38778",
        "e8e2531b-f663-43a3-8086-71f7c8e0ff6e"
    };
    vars.MinorIslandTowers = new List<string> {
        "a0d0ccf5-d1eb-4b55-a046-f332e801edf7", // Ancient Hill
        "a0dde0b2-e004-47c4-9da0-8102eebe5088", // Singing Peaks
        "0192abb4-3f62-47cc-b3ea-73b11c9ca2b6"  // Sailing Isle
    };
    vars.GodStatues = new List<string> {
        "447b21aa-130f-4991-898e-045adb41031d",
        "b7d7418d-94b4-4217-a646-97bcbf35df56",
        "67fc748b-f196-486c-bdeb-d0eb6e2f2ac7"
    };
    vars.EndingCutscene = "800c063d-fdcd-478b-b577-020b7363dd87";

    settings.Add("split_minor", false, "Split on minor objective completed");
    settings.Add("split_challenge_river", false, "River Island Challenges", "split_minor");
    settings.Add("split_challenge_desert", false, "Great Desert Challenges", "split_minor");
    settings.Add("split_challenge_volcano", false, "The Volcano Challenges", "split_minor");
    
    settings.Add("split_tower", true, "Split on minor island tower activated");
    settings.Add("split_statue", true, "Split on God Statue activated");
}

init {
    SigScanTarget SigSequenceManager = new SigScanTarget(3, "48 8B 05 ?? ?? ?? ?? 48 8B 88 B8 00 00 00 48 8B 01 48 85 C0 0F 84 ?? ?? ?? ?? 0F B6 70 40") {
        OnFound = (p, s, ptr) => ptr + 0x4 + game.ReadValue<int>(ptr)
    };
    SigScanTarget SigSceneManager = new SigScanTarget(22, "48 85 C0 0F 84 ?? ?? ?? ?? 80 78 58 00 0F 85 ?? ?? ?? ?? 48 8B 0D ?? ?? ?? ?? 83 B9 E4 00 00 00 00") {
        OnFound = (p, s, ptr) => ptr + 0x4 + game.ReadValue<int>(ptr)
    };
    SigScanTarget SigPauseManager = new SigScanTarget(3, "48 8B 05 ?? ?? ?? ?? 48 8B 88 B8 00 00 00 48 8B 01 48 85 C0 74 74 80 78 40 00") {
        OnFound = (p, s, ptr) => ptr + 0x4 + game.ReadValue<int>(ptr)
    };

    var module = modules.First(m => m.ModuleName == "GameAssembly.dll");
    SignatureScanner scanner = new SignatureScanner(game, module.BaseAddress, module.ModuleMemorySize);
    var sequenceManager = scanner.Scan(SigSequenceManager);
    print("SequenceManager: GameAssembly.dll+" + (sequenceManager.ToInt64() - module.BaseAddress.ToInt64()).ToString("X"));
    var sceneManager = scanner.Scan(SigSceneManager);
    print("SceneManager: GameAssembly.dll+" + (sceneManager.ToInt64() - module.BaseAddress.ToInt64()).ToString("X"));
    var pauseManager = scanner.Scan(SigPauseManager);
    print("PauseManager: GameAssembly.dll+" + (pauseManager.ToInt64() - module.BaseAddress.ToInt64()).ToString("X"));

    vars.Watchers = new MemoryWatcherList
    {
        new MemoryWatcher<long>(new DeepPointer(sequenceManager, 0xB8, 0x00, 0x100)) { Name = "currentSequence" },
        new StringWatcher(new DeepPointer(sequenceManager, 0xB8, 0x00, 0x100, 0x30, 0x14), 72) { Name = "sequenceGuid" },

        new MemoryWatcher<float>(new DeepPointer(pauseManager, 0xB8, 0x00, 0x80)) { Name = "totalPlaytime" },

        new MemoryWatcher<int>(new DeepPointer(sceneManager, 0xB8, 0x00, 0x50, 0x18)) { Name = "loadingOperations" },
        new MemoryWatcher<int>(new DeepPointer(sceneManager, 0xB8, 0x00, 0x58, 0x18)) { Name = "unloadingOperations" },
        new MemoryWatcher<int>(new DeepPointer(sceneManager, 0xB8, 0x00, 0x74)) { Name = "coreScenesLoaded" },
        new MemoryWatcher<bool>(new DeepPointer(sceneManager, 0xB8, 0x00, 0x90)) { Name = "isLoadingScenes" }
    };

    vars.Watchers.UpdateAll(game);
}

update {
    vars.Watchers.UpdateAll(game);
    current.currentSequence = vars.Watchers["currentSequence"].Current;
    current.sequenceGuid = vars.Watchers["sequenceGuid"].Current;
    current.totalPlaytime = vars.Watchers["totalPlaytime"].Current;
    current.loadingOperations = vars.Watchers["loadingOperations"].Current;
    current.unloadingOperations = vars.Watchers["unloadingOperations"].Current;
    current.coreScenesLoaded = vars.Watchers["coreScenesLoaded"].Current;
    current.isLoadingScenes = vars.Watchers["isLoadingScenes"].Current;

    current.allLoadingOperations = current.loadingOperations + current.unloadingOperations;
    if(current.currentSequence != old.currentSequence) {
        print("currentSequence: " + current.currentSequence.ToString("X"));
    }

    if (current.sequenceGuid != old.sequenceGuid) {
        print("sequenceGuid: " + current.sequenceGuid);
    }
    if (current.allLoadingOperations != old.allLoadingOperations) {
        print("loadingOperations: " + current.allLoadingOperations);
    }
    if (current.coreScenesLoaded != old.coreScenesLoaded) {
        print("coreScenesLoaded: " + current.coreScenesLoaded);
    }
}

start {
    if (current.currentSequence == 0 && old.currentSequence != 0 && old.sequenceGuid == "") {
        return true;
    }
}

split {
    if (current.sequenceGuid != old.sequenceGuid && current.sequenceGuid != "") {
        if (current.sequenceGuid == vars.EndingCutscene) {
            return true;
        }
        if (settings["split_challenge_river"] && vars.RiverChallenges.Contains(current.sequenceGuid)) {
            return true;
        }
        if (settings["split_challenge_desert"] && vars.DesertChallenges.Contains(current.sequenceGuid)) {
            return true;
        }
        if (settings["split_challenge_volcano"] && vars.VolcanoChallenges.Contains(current.sequenceGuid)) {
            return true;
        }
        if (settings["split_tower"] && vars.MinorIslandTowers.Contains(current.sequenceGuid)) {
            return true;
        }
        if (settings["split_statue"] && vars.GodStatues.Contains(current.sequenceGuid)) {
            return true;
        }
    }
}

isLoading
{
    bool isMainManuOpen = current.isLoadingScenes || current.coreScenesLoaded == 0;
    bool isLevelTransitionActive = current.allLoadingOperations > 0 && current.totalPlaytime == old.totalPlaytime;
    
    return isMainManuOpen || isLevelTransitionActive;
}