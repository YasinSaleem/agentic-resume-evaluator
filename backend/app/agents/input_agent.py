# backend/app/agents/input_agent.py
import io
from PyPDF2 import PdfReader
from docx import Document


class InputAgent:
    @staticmethod
    def parse_resume_file(file_bytes: bytes, filename: str) -> str:
        """
        Detect file type by extension and extract text accordingly.

        Args:
            file_bytes (bytes): The raw bytes of the file.
            filename (str): The name of the uploaded file to determine file type.

        Returns:
            str: Extracted plain text from resume.
        """
        if filename.lower().endswith('.pdf'):
            return InputAgent._parse_pdf(file_bytes)
        elif filename.lower().endswith(('.doc', '.docx')):
            return InputAgent._parse_docx(file_bytes)
        else:
            raise ValueError("Unsupported file type. Please upload a PDF or DOCX file.")

    @staticmethod
    def _parse_pdf(file_bytes: bytes) -> str:
        text = []
        buffer = io.BytesIO(file_bytes)
        reader = PdfReader(buffer)
        for page in reader.pages:
            text.append(page.extract_text() or '')
        return '\n'.join(text)

    @staticmethod
    def _parse_docx(file_bytes: bytes) -> str:
        buffer = io.BytesIO(file_bytes)
        document = Document(buffer)
        paragraphs = [p.text for p in document.paragraphs if p.text.strip() != '']
        return '\n'.join(paragraphs)
