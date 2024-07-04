/*
 * Autosplitter by Maltaran
 * Game: Patapon
 * PPSSPP versions: 1.7 - 1.17.1
 * Game verisons: European, American and Japanese
 */
state("PPSSPPWindows64") { }

startup
{
    settings.Add("option", false, "Split on failed missions");
}

init
{
    vars.watchers = new MemoryWatcherList();
    version = modules.First().FileVersionInfo.FileVersion;
    if (game.MainWindowTitle.Contains("UCES00995")) {
        version += " EU";
        vars.v1offset = 0x8EBAF50;
        vars.v2offset = 0x8D56AE4;
        vars.region = "EU";
    }
    else if (game.MainWindowTitle.Contains("UCUS98711")) {
        version += " US";
        vars.v1offset = 0x8EBB290;
        vars.v2offset = 0x8D56AE4;
        vars.region = "US";
    }
    else if (game.MainWindowTitle.Contains("UCJS10077")) {
        version += " JP";
        vars.v1offset = 0x8F566D0;
        vars.v2offset = 0x8D40A04;
        vars.region = "JP";
    }
    else vars.region = "x";
    switch (modules.First().FileVersionInfo.FileVersion) {
        case "v1.17.1":
            vars.baseOffset = 0xF9B000; break;
        case "v1.17":
            vars.baseOffset = 0xF95EA0; break;
        case "v1.16.6":
            vars.baseOffset = 0xF71E30; break;
        case "v1.16.5":
            vars.baseOffset = 0xF71E60; break;
        case "v1.16.4":
            vars.baseOffset = 0xF70E60; break;
        case "v1.16.3":
            vars.baseOffset = 0xF6EE60; break;
        case "v1.16.2":
        case "v1.16.1":
            vars.baseOffset = 0xF6CE60; break;
        case "v1.16":
            vars.baseOffset = 0xF6CD60; break;
        case "v1.15.4":
            vars.baseOffset = 0xEFECC0; break;
        case "v1.15.3":
        case "v1.15.2":
        case "v1.15.1":
            vars.baseOffset = 0xEFED20; break;
        case "v1.15":
            vars.baseOffset = 0xEFCD20; break;
        case "v1.14.4":
            vars.baseOffset = 0xDF7E58; break;
        case "v1.14.3":
            vars.baseOffset = 0xDF7E58; break;
        case "v1.14.2":
            vars.baseOffset = 0xDF6E58; break;
        case "v1.14.1":
            vars.baseOffset = 0xDF5DD8; break;
        case "v1.14":
            vars.baseOffset = 0xDF5C68; break;
        case "v1.13.2":
            vars.baseOffset = 0xDF10F0; break;
        case "v1.13.1":
            vars.baseOffset = 0xDEA130; break;
        case "v1.13":
            vars.baseOffset = 0xDE90F0; break;
        case "v1.12.3":
        case "v1.12.2":
        case "v1.12.1":
            vars.baseOffset = 0xD96108; break;
        case "v1.12":
            vars.baseOffset = 0xD960F8; break;
        case "v1.11.3":
        case "v1.11.2":
        case "v1.11.1":
            vars.baseOffset = 0xC6A440; break;
        case "v1.11":
            vars.baseOffset = 0xC68320; break;
        case "v1.10.3":
            vars.baseOffset = 0xC54CB0; break;
        case "v1.10.2":
            vars.baseOffset = 0xC53CB0; break;
        case "v1.10.1":
            vars.baseOffset = 0xC53B00; break;
        case "v1.10":
            vars.baseOffset = 0xC53AC0; break;
        case "v1.9.3":
            vars.baseOffset = 0xD8C010; break;
        case "v1.9":    
            vars.baseOffset = 0xD8AF70; break;
        case "v1.8.0":
            vars.baseOffset = 0xDC8FB0; break;
        case "v1.7.4":
        case "v1.7.1":
            vars.baseOffset = 0xD91250; break;
        case "v1.7":
            vars.baseOffset = 0xD90250; break;
        default:
            version += " (unsupported)"; return;
    }
    if (vars.region != "x") {
        vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.baseOffset, vars.v1offset)) { Name = "v1" });
        vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.baseOffset, vars.v2offset)) { Name = "v2" });
        //vars.watchers.Add(new StringWatcher(new DeepPointer(vars.offset, vars.offsetMission), 7) { Name = "Mission" });
    }
    
}

update
{
    vars.watchers.UpdateAll(game);
    if (vars.region == "x") {
        if (Process.GetProcessById(game.Id).MainWindowTitle.Contains("UCES00995")) {
            version += " EU";
            vars.v1offset = 0x8EBAF50;
            vars.v2offset = 0x8D56AE4;
            vars.region = "EU";
        }
        else if (Process.GetProcessById(game.Id).MainWindowTitle.Contains("UCUS98711")) {
            version += " US";
            vars.v1offset = 0x8EBB290;
            vars.v2offset = 0x8D56AE4;
            vars.region = "US";
        }
        else if (Process.GetProcessById(game.Id).MainWindowTitle.Contains("UCJS10077")) {
            version += " JP";
            vars.v1offset = 0x8F566D0;
            vars.v2offset = 0x8D40A04;
            vars.region = "JP";
        }
        if (vars.region != "x") {
            vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.baseOffset, vars.v1offset)) { Name = "v1" });
            vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.baseOffset, vars.v2offset)) { Name = "v2" });
            //vars.watchers.Add(new StringWatcher(new DeepPointer(vars.offset, vars.offsetMission), 7) { Name = "Mission" });
        }
    }
}

start
{
    if (vars.region != "x" && vars.watchers["v1"].Current > 5 && vars.watchers["v1"].Current < 10 && vars.watchers["v1"].Old == 5) return true;
}

split
{
    if (vars.watchers["v2"].Current == 1 && vars.watchers["v2"].Old == 0) return true;
    if (settings["option"] && vars.watchers["v2"].Current == 3 && vars.watchers["v2"].Old == 0) return true;
}
