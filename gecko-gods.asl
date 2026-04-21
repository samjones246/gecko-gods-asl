state("GeckoGods") {
    long currentSequence: "GameAssembly.dll", 0x32302B8, 0xB8, 0x00, 0x100;
    string255 sequenceGuid: "GameAssembly.dll", 0x32302B8, 0xB8, 0x00, 0x100, 0x30, 0x14;
}

update {
    if(current.currentSequence != old.currentSequence) {
        print("currentSequence: " + current.currentSequence.ToString("X"));
    }

    if (current.sequenceGuid != old.sequenceGuid) {
        print("sequenceGuid: " + current.sequenceGuid);
    }
}

start {
    if (current.currentSequence == 0 && old.currentSequence != 0 && old.sequenceGuid == "") {
        return true;
    }
}

split {
    if (current.sequenceGuid != old.sequenceGuid) {
        if (current.sequenceGuid == "800c063d-fdcd-478b-b577-020b7363dd87") {
            return true;
        }
    }
}