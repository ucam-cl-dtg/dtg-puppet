node /sa497-crunch(-\d+)?/ {
    include 'dtg::minimal'

    Dtg::Add_user['sa497'] {
        groups +> ['adm'],
    }
}
