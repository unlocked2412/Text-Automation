(() => {
    "use strict";

    // main :: IO ()
    const main = () => {
        const inner = () => {
            const
                ds = Application("TaskPaper")
                .documents;

            return either(alert("Problem"))(x => x)(
                bindLR(
                    0 < ds.length ? (
                        Right(ds.at(0))
                    ) : Left("No TaskPaper documents open")
                )(
                    d => d.evaluate({
                        script: tp3Context.toString(),
                        withOptions: {}
                    })
                )
            );
        };

        // -------------- TASKPAPER CONTEXT --------------
        // tp3Context :: (Editor, Dict) -> Either String a
        const tp3Context = (editor, options) => {
            // main :: ()
            const main = () => {
                const
                    outline = editor.outline,
                    seln = editor.selection,
                    item = seln.startItem,
                    locn = seln.startOffset,
                    xs = isProject(item) ? (
                        [item]
                    ) : item.ancestors.filter(isProject);

                return bindLR(
                    0 === xs.length ? (
                        Left("No parent project")
                    ) : Right(last(xs))
                )(
                    x => (
                        editor.focusedItem = x,
                        editor.moveSelectionToItems(item, locn),
                        Right(`Focused on project "${
                            x.bodyContentString
                        }"`)
                    )
                )
            };

            // FUNCTIONS ----------------------------------------------------
            // TASKPAPER 3 --------------------------------------------------
            // isProject :: TP3Item -> Bool
            const isProject = x =>
                "project" === x.getAttribute("data-type")

            // GENERIC FUNCTIONS --------------------------------------------
            // https://github.com/RobTrew/prelude-jxa
            // Right :: b -> Either a b
            const Right = x => ({
                type: "Either",
                Right: x
            });

            // Left :: a -> Either a b
            const Left = x => ({
                type: "Either",
                Left: x
            });

            // bindLR (>>=) :: Either a ->
            // (a -> Either b) -> Either b
            const bindLR = m =>
                mf => m.Left ? (
                    m
                ) : mf(m.Right);

            // last :: [a] -> a
            const last = xs =>
                // The last item of a list.
                0 < xs.length ? (
                    xs.slice(-1)[0]
                ) : null;

            return main();
        };

        // alert :: String => String -> IO String
        const alert = title => s => {
            const
                sa = Object.assign(Application("System Events"), {
                    includeStandardAdditions: true
                });

            return (
                sa.activate(),
                sa.displayDialog(s, {
                    withTitle: title,
                    buttons: ["OK"],
                    defaultButton: "OK",
                    withIcon: sa.pathToResource("TaskPaper.icns", {
                        inBundle: "Applications/TaskPaper.app"
                    })
                }),
                s
            );
        };

        return inner();
    };

    // GENERIC FUNCTIONS --------------------------------------------
    // https://github.com/RobTrew/prelude-jxa
    // Right :: b -> Either a b
    const Right = x => ({
        type: "Either",
        Right: x
    });

    // Left :: a -> Either a b
    const Left = x => ({
        type: "Either",
        Left: x
    });

    // bindLR (>>=) :: Either a ->
    // (a -> Either b) -> Either b
    const bindLR = m =>
        mf => m.Left ? (
            m
        ) : mf(m.Right);

    // either :: (a -> c) -> (b -> c) -> Either a b -> c
    const either = fl =>
        // Application of the function fl to the
        // contents of any Left value in e, or
        // the application of fr to its Right value.
        fr => e => "Left" in e ? (
            fl(e.Left)
        ) : fr(e.Right);

    // MAIN ------------------------------------------------
    return main()
})();
