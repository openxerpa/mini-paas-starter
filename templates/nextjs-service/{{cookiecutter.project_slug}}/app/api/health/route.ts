import { NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json({
    service: "{{ cookiecutter.project_slug }}",
    status: "ok",
  });
}
