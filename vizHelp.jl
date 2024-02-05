function saveHelp()
    println( 
    """ 
    \tsaveas FILENAME.vaca                         Saves the animation into a readable .VAC animation format.
    \tsaveas FILENAME.jdl                          Saves the raw binary animation into a compressed and portable JDL file.
    """
    )
end

function loadHelp()
    println(
    """
    """
    )
end

function navHelp()
    println( 
    """ 
    \tpr
    \tnx
    \tfocus
    \tpreview
    """
    )
end

function actionHelp()
    println(
    """
    \tdelete
    \tduplicate
    \tmove
    \tswap
    """
    )    
end

