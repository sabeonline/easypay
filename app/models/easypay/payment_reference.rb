module Easypay
  class PaymentReference < ActiveRecord::Base
    self.table_name = 'easypay_payment_references'

    # attr protected not used anymore in rails 4
    # attr_protected

    # TODO validate witch params are worth updating
    # TODO validate if listing is needed
    def update_data_from_listing(payment_reference)
       self.update_attributes( :payable_type => payable_type,
                                :ep_message => payment_reference["ep_message"],
                                :ep_reference => payment_reference["ep_reference"],
                                :ep_cin => payment_reference["ep_cin"],
                                :ep_doc => payment_reference["ep_doc"],
                                :ep_user => payment_reference["ep_user"],
                                :ep_payment_type => payment_reference["ep_payment_type"],
                                :ep_entity => payment_reference["ep_entity"],
                                :ep_link => payment_reference["payment_link"],
                                :ep_last_status => payment_reference["ep_status"],
                                :ep_value_fixed => payment_reference["ep_value_fixed"],
                                :ep_value_var => payment_reference["ep_value_var"],
                                :ep_value_tax => payment_reference["ep_value_tax"],
                                :ep_value_transf => payment_reference["ep_value_transf"],
                                :ep_date_transf => payment_reference["ep_date_transf"],
                                :ep_date_read => payment_reference["ep_date_read"],
                                :ep_status_read => payment_reference["ep_status_read"],
                                :ep_status => payment_reference["ep_status"],
                                :request_log => payment_reference["raw"],
                                :item_description => self.item_description,
                                :item_quantity => self.item_quantity,
                                :o_name  => self.o_name,
                                :o_description  => self.o_description,
                                :o_obs => self.o_obs,
                                :o_email => self.o_email,
                                :o_mobile  => self.o_mobile) if payment_reference
                                # "ep_payment_date"=>"2013-12-04 12:58:54"
    end

    def process(object, options = {})
      @object = object
      payable_type = @object.class.to_s



      if compliant?
        self.update_attributes(handle_model_methods)

        payment_reference = Client.new(options).create_reference(self)

        self.update_attributes( :payable_type => payable_type,
                                :ep_message => payment_reference["ep_message"],
                                :ep_reference => payment_reference["ep_reference"],
                                :ep_cin => payment_reference["ep_cin"],
                                :ep_user => payment_reference["ep_user"],
                                :ep_entity => payment_reference["ep_entity"],
                                :ep_link => payment_reference["ep_link"],
                                :ep_last_status => payment_reference["ep_status"],
                                :request_log => payment_reference["raw"],
                                :ep_boleto => payment_reference["ep_boleto"],
                                :item_description => self.item_description,
                                :item_quantity => self.item_quantity,
                                :o_name  => self.o_name,
                                :o_description  => self.o_description,
                                :o_obs => self.o_obs,
                                :o_email => self.o_email,
                                :o_mobile  => self.o_mobile)

        return payment_reference
      else
        nil
      end
    end

    # Update or delete payment reference
    def modify(action, options = {})
      @object = self

      response = Client.new(options).modify_payment_reference(self, action)

      if action.to_s.match("delete")
        self.update_attributes(:ep_status => "deleted") if response[:ep_status].starts_with? "ok"
      else
        self.update_attributes(:item_description => self.item_description,
                               :item_quantity => self.item_quantity,
                               :o_name  => self.o_name,
                               :o_description  => self.o_description,
                               :o_obs => self.o_obs,
                               :o_email => self.o_email,
                               :o_mobile  => self.o_mobile)
      end

      return response
    end

    protected

    def handle_model_methods
      attributes = {}
      model_attributes.each do |attribute_name, method_name|
        if @object.respond_to? method_name
          attributes[attribute_name] = @object.send(method_name)
        elsif !attribute_name.to_s.match("ep_key").nil?
          attributes[attribute_name] = method_name
        end
      end
      return attributes
    end

    def model_attributes
      {
        :payable_id => @object.easypay_options[:payable_id],
        :ep_key => generate_ep_key,
        :ep_value => @object.easypay_options[:ep_value],
        :ep_language  => @object.easypay_options[:ep_language],
        :o_name  => @object.easypay_options[:o_name],
        :o_description  => @object.easypay_options[:o_description],
        :o_obs => @object.easypay_options[:o_obs],
        :o_email => @object.easypay_options[:o_email],
        :o_mobile  => @object.easypay_options[:o_mobile],
        :item_description => @object.easypay_options[:item_description],
        :item_quantity => @object.easypay_options[:item_quantity]
      }
    end

    def compliant?
      !(@object.send(@object.easypay_options[:ep_language]).blank? && @object.send(@object.easypay_options[:ep_value]).blank?)
    end

    def generate_ep_key
      Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{@object.easypay_options[:ep_value]}--#{@object.easypay_options[:ep_language]}--")[8..32]
    end
  end
end
