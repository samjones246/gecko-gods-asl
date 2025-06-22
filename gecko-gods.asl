state("GeckoGods") { }

startup {
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "Gecko Gods";
    vars.Helper.LoadSceneManager = true;
    vars.Helper.StartFileLogger("GeckoGodsASL.log");
}

init
{
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => {
        var sequenceManager = mono["GeckoGame", "Inresin.Core.IRSequenceManager"];
        vars.Helper["sequence"] = sequenceManager
            .MakeString("_instance", "currentSequence", 0x10, 0x30, 0x60);
        return true;
    });
}

update {
    if (!string.IsNullOrEmpty(vars.Helper.Scenes.Active.Name)) { 
        current.scene = vars.Helper.Scenes.Active.Name;
    }

    if (current.scene != old.scene) {
        vars.Log("scene: " + current.scene);
    }
    if (current.sequence != old.sequence) {
        vars.Log("sequence: " + current.sequence);
    }
}

start {
    return false; //current.sequence != old.sequence && old.sequence == "IntroCutsceneV3";
}

split {
    return false; //current.sequence != old.sequence && current.sequence == "EndDemoSequence";
}