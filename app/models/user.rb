class User < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    
    validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
    
    validate :phone_format
    validates :phone, uniqueness: true
    
    validate :cpf_format
    validates :cpf, uniqueness: true
    validate :cpf_digits

    before_validation :ajustar_cpf
    validates :cpf, uniqueness: true
 
    
    before_validation :ajustar_phone
    validates :phone, uniqueness: true

    
    
    def phone_format
        # Define um vetor de formatos de números permitidos
        allowed_phone_formats = [
            /\A\d{11}\z/,                    # Formato: 00000000000      >
            /\A\(\d{2}\)\d{5}\-\d{4}\z/,     # Formato: (00)00000-0000   > celulares
            /\A\+\d{13}\z/,                  # Formato: +0000000000000   >
            /\A\d{10}\z/,                    # Formato: 0000000000       }
            /\A\(\d{2}\)\d{4}\-\d{4}\z/,     # Formato: (00)0000-0000    } números fixos
            /\A\+\d{12}\z/                   # Formato: +000000000000    }
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
            errors.add(:cpf, " fora do formato permitido") 
        end 
    end

    def cpf_digits
        #Checa se os últimos 2 digitos são validos diante do algoritmo do cpf
        cpf_cleanString = cpf.gsub(/\D/,'')
        cpf_int = cpf_cleanString.to_i 
        
        soma = 0
        for i in (10).downto(2)
          temp = ((cpf_int/10**i)%10) * i
          soma = soma + temp
        end
        
        soma2 = 0
        for j in (11).downto(2)
          temp = ((cpf_int/10**(j-1))%10) * j
          soma2 = soma2 + temp
        end
        
        resto = soma % 11
        if resto < 2
            comp = 0
        else
            comp = 11 - resto
        end

        resto2 = soma2 % 11
        
        if resto2 < 2
            comp2 = 0
        else
            comp2 = 11 - resto2 
        end

        cpf_digito_um = (cpf_int/10)%10
        cpf_digito_dois = cpf_int%10

        if ((comp != cpf_digito_um or comp2 != cpf_digito_dois) or all_digits_same?(cpf))
            errors.add(:cpf, "número de cpf invalido")
        end
    end

    


    private

    def ajustar_cpf
        original = self.cpf
        new_cpf = cpf.gsub(/\D/,'')
        self.cpf = cpf.gsub(/\D/,'')
    end

    def uniqueness_cpf
        if self.cpf_changed? && User.exists?(cpf: self.cpf)
            errors.add(:cpf, "o cpf digitado já foi utilizado")
        end
    end


    def ajustar_phone
        self.phone = self.phone.gsub(/\D/,'')
        if((self.phone.length != 12) && (self.phone.length != 13))
            self.phone = "+55" + self.phone
        else
            self.phone = "+" + self.phone
        end
    end

    def all_digits_same?(input_string)
        # Use a regular expression to check if all 11 digits are the same
        return input_string.match(/\A(\d)\1{10}\z/) != nil
      end
        

end
