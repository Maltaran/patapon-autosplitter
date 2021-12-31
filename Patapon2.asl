/*
 * Autosplitter by Maltaran
 * Game: Patapon 2
 * PPSSPP versions: 1.7 - 1.12.3
 * Game verisons: European and American
 */
state("PPSSPPWindows64") { }

startup
{
    settings.Add("fail", false, "Split on failed missions");
    settings.Add("unique", true, "Don't split on missions already completed once");
}

init
{
    vars.completed = new HashSet<string>();
    vars.watchers = new MemoryWatcherList();
    version = modules.First().FileVersionInfo.FileVersion;
    if (game.MainWindowTitle.Contains("UCES01177")) {
        version += " EU";
        vars.v1offset = 0x8EABFD0;
        vars.v2offset = 0x8D3AC2C;
        vars.v3offset = 0x8D33ED4;  
        vars.region = "EU";      
    }
    else if (game.MainWindowTitle.Contains("UCUS98732")) {
        version += " US";
        vars.v1offset = 0x8EABB90;
        vars.v2offset = 0x8D39C2C;
        vars.v3offset = 0x8D32EF0;
        vars.region = "US";
    }
    else vars.region = "x";
    switch (modules.First().FileVersionInfo.FileVersion) {
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
        vars.watchers.Add(new StringWatcher(new DeepPointer(vars.baseOffset, vars.v3offset), 5) { Name = "v3" });
    }
}

update
{
    vars.watchers.UpdateAll(game);
    if (vars.region == "x") {
        if (Process.GetProcessById(game.Id).MainWindowTitle.Contains("UCES01177")) {
            version += " EU";
            vars.v1offset = 0x8EABFD0;
            vars.v2offset = 0x8D3AC2C;
            vars.v3offset = 0x8D33ED4;  
            vars.region = "EU";      
        }
        else if (Process.GetProcessById(game.Id).MainWindowTitle.Contains("UCUS98732")) {
            version += " US";
            vars.v1offset = 0x8EABB90;
            vars.v2offset = 0x8D39C2C;
            vars.v3offset = 0x8D32EF0;
            vars.region = "US";
        }
        if (vars.region != "x") {
            vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.baseOffset, vars.v1offset)) { Name = "v1" });
            vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.baseOffset, vars.v2offset)) { Name = "v2" });
            vars.watchers.Add(new StringWatcher(new DeepPointer(vars.baseOffset, vars.v3offset), 5) { Name = "v3" });
        }
    }
    else if (vars.watchers["v3"].Current == "00_00" && vars.watchers["v3"].Old != "00_00")
        vars.completed = new HashSet<string>();
}

start
{
    if (vars.watchers["v1"].Current > 5 && vars.watchers["v1"].Current < 10 && vars.watchers["v1"].Old == 5) {
        vars.completed = new HashSet<string>();
        return true;
    }
}

split
{
    if (vars.watchers["v2"].Current == 1 && vars.watchers["v2"].Old == 0) {
        if (!(settings["unique"] && vars.completed.Contains(vars.watchers["v3"].Current))) {
            vars.completed.Add(vars.watchers["v3"].Current);
            if (vars.watchers["v3"].Current != "10710") return true;
        }
        else if (vars.watchers["v3"].Current == "10710") {
            return true;
        }
    }
    else if (vars.watchers["v2"].Current == 3 && settings["fail"] && vars.watchers["v2"].Old == 0) {
        if (!(settings["unique"] && vars.completed.Contains(vars.watchers["v3"].Current))) {
            return true;
        }
    }
}
