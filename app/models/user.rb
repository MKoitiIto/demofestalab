class User < ApplicationRecord
    attr_accessor :cpf_input
    
    validates :name, presence: true, uniqueness: true
    
    validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
    
    validates :phone, presence: true
    validate :validate_format_and_uniqueness, if: -> { phone.present? }
    
    validates :cpf, presence: true
    validate :validate_format_and_uniqueness, if: -> { cpf.present? }


    private

    def validate_format_and_uniqueness
        cpf_stripped = cpf.gsub(/\D/, '') # retira os caracteres nao-numericos da string do cpf
        existing_user = User.find_by("cpf = :cpf OR cpf = :cpf_stripped", cpf: cpf, cpf_stripped: cpf_stripped)
    
        if valid_cpf_format?(cpf) && existing_user.nil?
          self.cpf = cpf_stripped
        elsif !valid_cpf_format?(cpf)
          errors.add(:cpf, "is not a valid CPF")
        else
          errors.add(:cpf, "already exists in the database")
        end
    end

    
    def valid_cpf_format?(cpf)
        # Define the allowed CPF formats
        allowed_cpf_formats = [
          /\A\d{3}\.\d{3}\.\d{3}\-\d{2}\z/,       # formato : 000.000.000-00
          /\A\d{11}\z/                            # formato : 00000000000
        ]
      
        # Checa se o cpf fornecido coincide com algum dos formatos possíveis
        valid_format = allowed_cpf_formats.any? { |format| format.match?(cpf) }
      
        # Se o formato é valido checa se o numero de cpf é válido 
        if valid_format
            cpf_clean = cpf.gsub(/\D/,'')
            cpf_int = cpf_clean.to_i 
            
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

            valid_digits = (comp == cpf_digito_um && comp2 == cpf_digito_dois) && !all_digits_same?(cpf_clean)
      
            return valid_digits
        end
    end
    
    def validate_format_and_uniqueness
        phone_cleaned = phone.gsub(/\D/, '') 
        phone_cleaned = self.phone.gsub(/\D/,'')
        if((phone_cleaned.length != 12) && (phone_cleaned.length != 13))
            phone_cleaned = "+55" + phone_cleaned
        else
            phone_cleaned = "+" + phone_cleaned
        end

        existing_user = User.find_by("phone = :phone OR phone = :phone_cleaned", phone: phone, phone_cleaned: phone_cleaned)

        if valid_phone_format?(phone) && existing_user.nil?
          self.phone = phone_cleaned
        elsif !valid_phone_format?(phone)
          errors.add(:phone, "is not a valid phone number")
        else
          errors.add(:phone, "número de telefone já utilizado")
        end
    end  
    
    
    
    def valid_phone_format?(phone)
        allowed_phone_formats = [
            /\A\d{11}\z/,                    # Formato: 00000000000      >
            /\A\(\d{2}\)\d{5}\-\d{4}\z/,     # Formato: (00)00000-0000   > celulares
            /\A\+\d{13}\z/,                  # Formato: +0000000000000   >
            /\A\d{10}\z/,                    # Formato: 0000000000       }
            /\A\(\d{2}\)\d{4}\-\d{4}\z/,     # Formato: (00)0000-0000    } números fixos
            /\A\+\d{12}\z/                   # Formato: +000000000000    }
        ]
        valid_format = allowed_phone_formats.any? { |format| format.match?(phone) }
        return valid_format
    end

    def all_digits_same?(input_string)
        # Use a regular expression to check if all 11 digits are the same
        return input_string.match(/\A(\d)\1{10}\z/) != nil
    end
        

end
