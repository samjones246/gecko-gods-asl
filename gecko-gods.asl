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
        vars.Helper["isCutsceneActive"] = sequenceManager
            .Make<bool>("_instance", 0x98);
        return true;
    });
}

start {
    return !current.isCutsceneActive && old.isCutsceneActive;
}

split {
    return current.isCutsceneActive && !old.isCutsceneActive;
}