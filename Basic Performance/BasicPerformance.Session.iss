objectdef bpSession
{
    method Initialize()
    {
        maxfps -fg 60
        maxfps -bg 30
    }
}

variable(global) bpSession BPSession

function main()
{
    while 1
        waitframe
}