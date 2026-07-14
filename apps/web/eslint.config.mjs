import {FlatCompat} from "@eslint/eslintrc";import path from "node:path";import {fileURLToPath} from "node:url";const dir=path.dirname(fileURLToPath(import.meta.url));const compat=new FlatCompat({baseDirectory:dir});export default [...compat.extends("next/core-web-vitals","next/typescript")];

