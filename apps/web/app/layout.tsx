import type {Metadata} from "next";import "./globals.css";import "./connections.css";
export const metadata:Metadata={title:{default:"Forever Games",template:"%s · Forever Games"},description:"Your games. Your legacy. A trusted demand layer for authorized physical preservation."};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="en"><body>{children}</body></html>}
