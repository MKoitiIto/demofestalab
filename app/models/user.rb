class User < ApplicationRecord
    validates :name, presence: true
    validates :email, presence: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
    validate :phone_format
    validate :cpf_format

    def phone_format
        # Define um vetor de formatos de números permitidos
        allowed_phone_formats = [
            /\A\d{11}\z/,                    # Formato: 00000000000
            /\A\(\d{2}\)\d{5}\-\d{4}\z/,     # Formato: (00)00000-0000
            /\A\+\d{13}\z/                   # Formato: +000000000000000
        ]

        # Checa se o número de telefone está dentro do vetor fornecido
        unless allowed_phone_formats.any? { |format| phone =~ format }
            errors.add(:phone, "número de telefone fora do formato permitido")
        end
    end

    def cpf_format
        # Define um vetor de formatos de CPF permitidos
        allowed_cpf_formats = [
            /\A\d{3}\.\d{3}\.\d{3}\-\d{2}\z/, # Formato: 000.000.000-00     
            /\A\d{11}\z/                      # Formato: 00000000000
        ]

        # Checa se o cpf fornecido está dentro do vetor fornecido
        unless allowed_cpf_formats.any? { |format| cpf =~ format }
            errors.add(:cpf, "cpf fora do formato permitido") 
        end 
    end

end
