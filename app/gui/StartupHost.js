.pragma library

// Stable IDs survive renames and reordered discovery results. Do not open an
// unpaired/offline host or silently choose a different machine.
function choose(hosts, wanted) {
    if (!wanted) return { index: -1, open: false }
    for (var i = 0; i < hosts.length; ++i) {
        var h = hosts[i]
        if (h && h.hostId === wanted)
            return { index: i, open: h.online && h.paired && !h.statusUnknown && h.serverSupported }
    }
    return { index: -1, open: false }
}
