state("GeckoGods") {
    long currentSequence: "GameAssembly.dll", 0x32302B8, 0xB8, 0x00, 0x100;
    string255 sequenceGuid: "GameAssembly.dll", 0x32302B8, 0xB8, 0x00, 0x100, 0x30, 0x14;
    float totalPlaytime: "GameAssembly.dll", 0x3230298, 0xB8, 0x00, 0x80;
    int loadingOperations: "GameAssembly.dll", 0x32307B0, 0xB8, 0x00, 0x50, 0x18;
    int unloadingOperations: "GameAssembly.dll", 0x32307B0, 0xB8, 0x00, 0x58, 0x18;
}

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

update {
    if(current.currentSequence != old.currentSequence) {
        print("currentSequence: " + current.currentSequence.ToString("X"));
    }

    if (current.sequenceGuid != old.sequenceGuid) {
        print("sequenceGuid: " + current.sequenceGuid);
    }
    if (current.loadingOperations != old.loadingOperations) {
        print("loadingOperations: " + current.loadingOperations);
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
    return current.totalPlaytime == old.totalPlaytime && (current.loadingOperations > 0 || current.unloadingOperations > 0);
}