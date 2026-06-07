# Activate aliases for Elvish.
# @note Updated 2026-05-01.
# Elvish uses function definitions for aliases.
fn activate-aliases {
    var bin-prefix = (bin-prefix)

    # Navigation.
    fn .. { cd .. }
    fn ... { cd ../.. }
    fn .... { cd ../../.. }
    fn ..... { cd ../../../.. }

    # Shortcuts.
    fn c { clear }
    fn e { exit }
    fn q { exit }
    fn g {|@a| e:git $@a }
    fn k {|@a| e:koopa $@a }

    # ls.
    if (path:is-regular &follow-symlink $bin-prefix'/eza') {
        fn l {|@a| e:eza --classify --color=auto $@a }
    } else {
        fn l {|@a| e:ls -BFhp $@a }
    }
    fn la {|@a| l -a $@a }
    fn ll {|@a| l -l $@a }

    # fd.
    if (path:is-regular &follow-symlink $bin-prefix'/fd') {
        fn fd {|@a| e:fd --absolute-path --ignore-case --no-ignore $@a }
    }

    # chezmoi.
    if (path:is-regular &follow-symlink $bin-prefix'/chezmoi') {
        fn cm {|@a| e:chezmoi $@a }
    }
}
