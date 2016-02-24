require 'sql_object'
require 'db_connection'
require 'searchable'
require 'db_info'
require 'associatable'
require 'securerandom'

describe SQLObject do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  context 'before ::finalize!' do
    before(:each) do
      class Player < SQLObject
      end
    end

    after(:each) do
      Object.send(:remove_const, :Player)
    end

    describe '::table_name' do
      it 'generates default name' do
        expect(Player.table_name).to eq('players')
      end
    end

    describe '::table_name=' do
      it 'sets table name' do
        class Manager < SQLObject
          self.table_name = 'managers'
        end

        expect(Manager.table_name).to eq('managers')

        Object.send(:remove_const, :Manager)
      end
    end

    describe '::columns' do
      it 'returns a list of all column names as symbols' do
        expect(Player.columns).to eq([:id, :name, :manager_id])
      end

      it 'only queries the DB once' do
        expect(DBConnection).to(
          receive(:execute2).exactly(1).times.and_call_original)
        3.times { Player.columns }
      end
    end

    describe '#attributes' do
      it 'returns @attributes hash byref' do
        player_attributes = {name: 'Harvey'}
        c = Player.new
        c.instance_variable_set('@attributes', player_attributes)

        expect(c.attributes).to equal(player_attributes)
      end

      it 'lazily initializes @attributes to an empty hash' do
        c = Player.new

        expect(c.instance_variables).not_to include(:@attributes)
        expect(c.attributes).to eq({})
        expect(c.instance_variables).to include(:@attributes)
      end
    end
  end

  context 'after ::finalize!' do
    before(:all) do
      class Player < SQLObject
        self.finalize!
      end

      class Manager < SQLObject
        self.table_name = 'managers'

        self.finalize!
      end
    end

    after(:all) do
      Object.send(:remove_const, :Player)
      Object.send(:remove_const, :Manager)
    end

    describe '::finalize!' do
      it 'creates getter methods for each column' do
        c = Player.new
        expect(c.respond_to? :something).to be false
        expect(c.respond_to? :name).to be true
        expect(c.respond_to? :id).to be true
        expect(c.respond_to? :manager_id).to be true
      end

      it 'creates setter methods for each column' do
        c = Player.new
        c.name = "Lucas Duda"
        c.id = 209
        c.manager_id = 2
        expect(c.name).to eq 'Lucas Duda'
        expect(c.id).to eq 209
        expect(c.manager_id).to eq 2
      end

      it 'created getter methods read from attributes hash' do
        c = Player.new
        c.instance_variable_set(:@attributes, {name: "Lucas Duda"})
        expect(c.name).to eq 'Lucas Duda'
      end

      it 'created setter methods use attributes hash to store data' do
        c = Player.new
        c.name = "Lucas Duda"

        expect(c.instance_variables).to include(:@attributes)
        expect(c.instance_variables).not_to include(:@name)
        expect(c.attributes[:name]).to eq 'Lucas Duda'
      end
    end

    describe '#initialize' do
      it 'calls appropriate setter method for each item in params' do

        c = Player.allocate

        expect(c).to receive(:name=).with('Don Mattingly')
        expect(c).to receive(:id=).with(100)
        expect(c).to receive(:manager_id=).with(4)

        c.send(:initialize, {name: 'Don Mattingly', id: 100, manager_id: 4})
      end

      it 'throws an error when given an unknown attribute' do
        expect do
          Player.new(favorite_band: 'Anybody but The Eagles')
        end.to raise_error "unknown attribute 'favorite_band'"
      end
    end

    describe '::all, ::parse_all' do
      it '::all returns all the rows' do
        players = Player.all
        expect(players.count).to eq(5)
      end

      it '::parse_all turns an array of hashes into objects' do
        hashes = [
          { name: 'player1', manager_id: 1 },
          { name: 'player2', manager_id: 2 }
        ]

        players = Player.parse_all(hashes)
        expect(players.length).to eq(2)
        hashes.each_index do |i|
          expect(players[i].name).to eq(hashes[i][:name])
          expect(players[i].owner_id).to eq(hashes[i][:manager_id])
        end
      end

      it '::all returns a list of objects, not hashes' do
        players = Player.all
        players.each { |player| expect(player).to be_instance_of(Player) }
      end
    end

    describe '::find' do
      it 'fetches single objects by id' do
        c = Player.find(1)

        expect(c).to be_instance_of(Player)
        expect(c.id).to eq(1)
      end

      it 'returns nil if no object has the given id' do
        expect(Player.find(123)).to be_nil
      end
    end

    describe '#attribute_values' do
      it 'returns array of values' do
        player = Player.new(id: 123, name: 'Lagares', manager_id: 1)

        expect(player.attribute_values).to eq([123, 'Lagares', 1])
      end
    end

    describe '#insert' do
      let(:player) { Player.new(name: 'Gizmo', manager_id: 1) }

      before(:each) { player.insert }

      it 'inserts a new record' do
        expect(Player.all.count).to eq(6)
      end

      it 'sets the id once the new record is saved' do
        expect(player.id).to eq(DBConnection.last_insert_row_id)
      end

      it 'creates a new record with the correct values' do
        player2 = Player.find(player.id)

        expect(player2.name).to eq('Gizmo')
        expect(player2.manager_id).to eq(1)
      end
    end

    describe '#update' do
      it 'saves updated attributes to the DB' do
        manager = Manager.find(2)

        manager.fname = 'Joe'
        manager.lname = 'Girardi'
        manager.update

        manager = Manager.find(2)
        expect(manager.fname).to eq('Joe')
        expect(manager.lname).to eq('Girardi')
      end
    end

    describe '#save' do
      it 'calls #insert when record does not exist' do
        manager = Manager.new
        expect(manager).to receive(:insert)
        manager.save
      end

      it 'calls #update when record already exists' do
        manager = Manager.find(1)
        expect(manager).to receive(:update)
        manager.save
      end
    end
  end
end
