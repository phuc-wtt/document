import { EditorView, basicSetup } from "codemirror"
import { javascript } from "@codemirror/lang-javascript"
import { useEffect, useRef } from "react"
import { CodeMirror, vim } from "@replit/codemirror-vim"


function App() {
  const codeWrapper = useRef(null)

  CodeMirror.commands.save = () => {
    console.log('save')
  }

  useEffect(()=> {
    console.log(CodeMirror.commands.save)
  })

  useEffect(()=> {
    if(!codeWrapper) return

    new EditorView({
      doc: "",
      extensions: [
        basicSetup,
        vim(),
      ],
      parent: codeWrapper.current,
    })

  }, [codeWrapper])

  return (
    <div>
      <h1>Hi</h1>
      <div id='codemirror' ref={codeWrapper}></div>
    </div>
  )
}

export default App
