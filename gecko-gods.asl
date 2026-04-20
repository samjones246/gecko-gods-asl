state("GeckoGods") {
    long currentSequence: "GameAssembly.dll", 0x3230288, 0xB8, 0x00, 0x100;
}

startup {
}

init
{
    print("" + current.currentSequence);
}

update {
    if(current.currentSequence != old.currentSequence) {
        print("" + current.currentSequence);
    }
}

start {
}

split {
}