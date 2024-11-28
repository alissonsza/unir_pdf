import os
import time
from tkinter import filedialog, messagebox, Menu, Toplevel, Label
import customtkinter as ctk
from PIL import Image, ImageTk
from PyPDF2 import PdfMerger


class PDFCreatorApp:
    def __init__(self, root):
        # Configurações iniciais
        self.root = root
        self.root.title("UNIR PDF")
        self.root.geometry("600x450")
        ctk.set_appearance_mode("System")
        ctk.set_default_color_theme("blue")

        self.file_list = []

        # Criar menu
        self.create_menu()

        # Título
        self.title_label = ctk.CTkLabel(root, text="UNIR PDF", font=("Arial", 20, "bold"))
        self.title_label.pack(pady=10)

        # Lista de arquivos
        self.frame = ctk.CTkFrame(root)
        self.frame.pack(fill="both", expand=True, padx=10, pady=10)

        self.file_listbox = ctk.CTkTextbox(self.frame, height=10, state="disabled", wrap="none")
        self.file_listbox.pack(side="left", fill="both", expand=True, padx=(5, 0))

        self.scrollbar = ctk.CTkScrollbar(self.frame, command=self.file_listbox.yview)
        self.file_listbox.configure(yscrollcommand=self.scrollbar.set)
        self.scrollbar.pack(side="right", fill="y")

        # Botões de controle
        self.control_frame = ctk.CTkFrame(root)
        self.control_frame.pack(pady=10)

        self.add_button = ctk.CTkButton(self.control_frame, text="Adicionar Arquivo", command=self.add_file)
        self.add_button.grid(row=0, column=0, padx=5)

        self.remove_button = ctk.CTkButton(self.control_frame, text="Remover Selecionado", command=self.remove_file)
        self.remove_button.grid(row=0, column=1, padx=5)

        self.up_button = ctk.CTkButton(self.control_frame, text="🔼", command=self.move_up, width=40)
        self.up_button.grid(row=0, column=2, padx=5)

        self.down_button = ctk.CTkButton(self.control_frame, text="🔽", command=self.move_down, width=40)
        self.down_button.grid(row=0, column=3, padx=5)

        self.merge_button = ctk.CTkButton(root, text="Unir PDF", command=self.merge_files)
        self.merge_button.pack(pady=20)

    def create_menu(self):
        """Cria o menu superior"""
        menu_bar = Menu(self.root)

        # Menu Arquivo
        file_menu = Menu(menu_bar, tearoff=0)
        file_menu.add_command(label="Sair", command=self.exit_app)
        menu_bar.add_cascade(label="Menu", menu=file_menu)

        # Menu Contribuir
        contribute_menu = Menu(menu_bar, tearoff=0)
        contribute_menu.add_command(label="Contribuir", command=self.show_contribute_message)
        menu_bar.add_cascade(label="Contribuir", menu=contribute_menu)

        # Adiciona o menu à janela principal
        self.root.config(menu=menu_bar)

    def exit_app(self):
        """Fecha o aplicativo"""
        self.root.quit()

    def show_contribute_message(self):
        """Mostra a mensagem de contribuição e o QR code"""
        pix_key = "1234-5678-9012-3456"  # Substitua pela sua chave PIX
        messagebox.showinfo("Contribuir", f"Caso queira contribuir, abaixo a chave PIX:\n\n{pix_key}")
        self.show_qrcode()

    def show_qrcode(self):
        """Exibe o QR Code em uma nova janela"""
        # Caminho para o arquivo do QR Code
        qrcode_path = "qrcode.png"  # Caminho do arquivo de imagem QR Code

        if os.path.exists(qrcode_path):
            # Abre a imagem e redimensiona
            img = Image.open(qrcode_path)
            img = img.resize((250, 250), Image.Resampling.LANCZOS)  # Usando LANCZOS no lugar de ANTIALIAS

            # Converte a imagem para o formato que o tkinter aceita
            img_tk = ImageTk.PhotoImage(img)

            # Cria uma nova janela para mostrar o QR code
            qr_window = Toplevel(self.root)
            qr_window.title("QR Code de Contribuição")
            qr_window.geometry("300x300")

            # Exibe a imagem na nova janela
            qr_label = Label(qr_window, image=img_tk)
            qr_label.pack()

            # Mantém uma referência à imagem
            qr_label.image = img_tk
        else:
            messagebox.showerror("Erro", "Arquivo QR Code não encontrado.")

    def add_file_to_list(self, file_path):
        if file_path not in self.file_list:
            self.file_list.append(file_path)
            self.update_listbox()

    def add_file(self):
        file_path = filedialog.askopenfilename(filetypes=[("PDF Files", "*.pdf")])
        if file_path:
            self.add_file_to_list(file_path)

    def remove_file(self):
        selected = self.get_selected_file()
        if selected:
            self.file_list.remove(selected)
            self.update_listbox()

    def move_up(self):
        selected = self.get_selected_file()
        if selected:
            idx = self.file_list.index(selected)
            if idx > 0:
                self.file_list[idx], self.file_list[idx - 1] = self.file_list[idx - 1], self.file_list[idx]
                self.update_listbox()

    def move_down(self):
        selected = self.get_selected_file()
        if selected:
            idx = self.file_list.index(selected)
            if idx < len(self.file_list) - 1:
                self.file_list[idx], self.file_list[idx + 1] = self.file_list[idx + 1], self.file_list[idx]
                self.update_listbox()

    def merge_files(self):
        if not self.file_list:
            messagebox.showerror("Erro", "Nenhum arquivo selecionado para unir.")
            return

        save_path = filedialog.asksaveasfilename(defaultextension=".pdf", filetypes=[("PDF Files", "*.pdf")])
        if not save_path:
            return

        merger = PdfMerger()
        for file in self.file_list:
            merger.append(file)

        merger.write(save_path)
        merger.close()
        messagebox.showinfo("Sucesso", "PDF criado com sucesso!")

    def update_listbox(self):
        self.file_listbox.configure(state="normal")
        self.file_listbox.delete("1.0", "end")
        for file in self.file_list:
            self.file_listbox.insert("end", file + "\n")
        self.file_listbox.configure(state="disabled")

    def get_selected_file(self):
        try:
            selected_text = self.file_listbox.get("sel.first", "sel.last").strip()
            return selected_text if selected_text in self.file_list else None
        except Exception:
            return None


if __name__ == "__main__":
    root = ctk.CTk()
    app = PDFCreatorApp(root)
    root.mainloop()
