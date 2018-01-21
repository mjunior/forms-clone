require 'rails_helper'

RSpec.describe "Api::V1::Forms", type: :request do
  describe "GET /forms" do
    context "With invalid authentication headers" do
      it_behaves_like :deny_without_authorization, :get, "/api/v1/forms"
    end

    context "With valid authentication header" do
      before do
        @user = create(:user)
        @form1 = create(:form, user: @user)
        @form2 = create(:form, user: @user)

        get "/api/v1/forms", params: {}, headers: header_with_authentication(@user)
      end

      it 'Return HTTP Status 200' do
        expect_status(200)
      end

      it 'Return list with two forms' do
        expect(json.count).to eql(2)
      end

      it 'Check that list form are right data' do
        
      end
    end
  end

  describe 'GET /forms/:id' do
    before do
      @user = create(:user)
    end

    context 'When the form exist' do
      #
      context 'When the form is enable' do
        before do
          @form = create(:form, user:@user, enable: true)
          get "/api/v1/forms/#{@form.friendly_id}", params: {}, headers: header_with_authentication(@user)
        end

        it 'Return HTTP Status 200' do
          expect_status(200)
        end
        
        it 'Return the form' do
          expect(json).to eql(JSON.parse(@form.to_json(include: :questions), symbolize_names: true))
        end
      end

      context 'When the form is disable' do
        before do
          @form = create(:form, user: @user, enable: false)
        end

        it 'Return HTTP Status 404' do
          get "/api/v1/forms/#{@form.friendly_id}", params: {}, headers: header_with_authentication(@user)
          expect_status(404)
        end
      end
    end

    context 'When the form does not exist' do
      it 'Return HTTP Status 404' do
        get "/api/v1/forms/este1-form2-nunca3-vai4-existir5",
          params: {},
          headers: header_with_authentication(@user)
        
        expect_status(404)
      end
    end

  end

  describe 'POST /forms' do
    context 'When the user is logged' do
      before do
        @user = create(:user)
      end

      context 'When the params is valid' do
        before do
          @form_params = attributes_for(:form)
          post "/api/v1/forms", params: {form: @form_params}, headers: header_with_authentication(@user)
        end

        it 'Return HTTP Status 200' do
          expect_status(200)
        end

        it "form are created with correct data" do
          @form_params.each do |field|
            expect(Form.first[field.first]).to eql(field.last)
          end
        end

        it "Returned data is correct" do
          
          @form_params.each do |field|
            expect(json[field.first.to_sym]).to eql(field.last)
          end
        end

      end

      context 'When the params is invalid' do
        before do
          @other_user = create(:user)
          post "/api/v1/forms", params: {form: {}}, headers: header_with_authentication(@other_user)
        end

        it "returns 400" do
          expect_status(400)
        end
      end

    end

    context 'When the user isnt logged' do
      it_behaves_like :deny_without_authorization, :post, "/api/v1/forms"
    end
  end

  describe "GET /forms/:friendly_id" do
    before do
      @user = create(:user)
    end

    context "When form exists" do

      context "And is enable" do
        before do
          @form = create(:form, user: @user, enable: true)
          @question1 = create(:question, form: @form)
          @question2 = create(:question, form: @form)

          get "/api/v1/forms/#{@form.friendly_id}", params: {}, headers: header_with_authentication(@user)
        end

        it "returns 200" do
          expect_status(200)
        end

        it "returned Form with right datas" do
          expect(json.except(:questions)).to eql(JSON.parse(@form.to_json, symbolize_names: true))
        end

        it "returned associated questions" do
          expect(json[:questions].first).to eql(JSON.parse(@question1.to_json, symbolize_names: true))
          expect(json[:questions].last).to  eql(JSON.parse(@question2.to_json, symbolize_names: true))
        end
      end

      context "And is unable" do
        before do
          @form = create(:form, user: @user, enable: false)
        end

        it "returns 404" do
          get "/api/v1/forms/#{FFaker::Lorem.word}", params: {id: @form.friendly_id}, headers: header_with_authentication(@user)
          expect_status(404)
        end
      end
    end

    context "When form dont exists" do
      it "returns 404" do
        get "/api/v1/forms/#{FFaker::Lorem.word}", params: {}, headers: header_with_authentication(@user)
        expect_status(404)
      end
    end
  end

  describe "DELETE /forms/:friendly_id" do
    before do
      @user = create(:user)
    end

    context "With Invalid authentication headers" do
      it_behaves_like :deny_without_authorization, :delete, "/api/v1/forms/questionary"
    end

    context "With valid authentication headers" do

      context "When form exists" do

        context "And user is the owner" do
          before do
            @form = create(:form, user: @user)
            @question = create(:question, form: @form)
            delete "/api/v1/forms/#{@form.friendly_id}", params: {}, headers: header_with_authentication(@user)
          end

          it "returns 200" do
            expect_status(200)
          end

          it "form are deleted" do
            expect(Form.all.count).to eql(0)
          end

          it "associated question are deleted" do
            expect(Question.all.count).to eql(0)
          end
        end

        context "And user is not the owner" do
          before do
            @form = create(:form)
            delete "/api/v1/forms/#{@form.friendly_id}", params: {}, headers: header_with_authentication(@user)
          end

          it "returns 403" do
            expect_status(403)
          end
        end
      end

      context "When form dont exists" do
        it "returns 404" do
          delete "/api/v1/forms/#{FFaker::Lorem.word}", params: {}, headers: header_with_authentication(@user)
          expect_status(404)
        end
      end

      context "When form exists" do

        context "And user is the owner" do
          before do
            @form = create(:form, user: @user)
            delete "/api/v1/forms/#{@form.friendly_id}", params: {}, headers: header_with_authentication(@user)
          end

          it "returns 200" do
            expect_status(200)
          end

          it "form are deleted" do
            expect(Form.all.count).to eql(0)
          end
        end

        context "And user is not the owner" do
          before do
            @form = create(:form)
            delete "/api/v1/forms/#{@form.friendly_id}", params: {}, headers: header_with_authentication(@user)
          end

          it "returns 403" do
            expect_status(403)
          end
        end
      end

      context "When form dont exists" do
        it "returns 404" do
          delete "/api/v1/forms/#{FFaker::Lorem.word}", params: {}, headers: header_with_authentication(@user)
          expect_status(404)
        end
      end
    end
  end
end
