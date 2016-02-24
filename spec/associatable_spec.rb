require 'sql_object'
require 'db_connection'
require 'searchable'
require 'db_info'
require 'associatable'
require 'securerandom'

describe 'AssocOptions' do
  describe 'BelongsToOptions' do
    it 'provides defaults' do
      options = BelongsToOptions.new('team')

      expect(options.foreign_key).to eq(:team_id)
      expect(options.class_name).to eq('Team')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = BelongsToOptions.new('manager',
                                     foreign_key: :manager_id,
                                     class_name: 'Manager',
                                     primary_key: :manager_id
      )

      expect(options.foreign_key).to eq(:manager_id)
      expect(options.class_name).to eq('Manager')
      expect(options.primary_key).to eq(:manager_id)
    end
  end

  describe 'HasManyOptions' do
    it 'provides defaults' do
      options = HasManyOptions.new('players', 'Manager')

      expect(options.foreign_key).to eq(:manager_id)
      expect(options.class_name).to eq('Player')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = HasManyOptions.new('players', 'Manager',
                                   foreign_key: :manager,
                                   class_name: 'Ballplayer',
                                   primary_key: :manager_id
      )

      expect(options.foreign_key).to eq(:manager)
      expect(options.class_name).to eq('Ballplayer')
      expect(options.primary_key).to eq(:manager_id)
    end
  end

  describe 'AssocOptions' do
    before(:all) do
      class Player < SQLObject
        self.finalize!
      end

      class Manager < SQLObject
        self.table_name = 'managers'

        self.finalize!
      end
    end

    it '#model_class returns class of associated object' do
      options = BelongsToOptions.new('manager')
      expect(options.model_class).to eq(Manager)

      options = HasManyOptions.new('players', 'Manager')
      expect(options.model_class).to eq(Player)
    end

    it '#table_name returns table name of associated object' do
      options = BelongsToOptions.new('manager')
      expect(options.table_name).to eq('managers')

      options = HasManyOptions.new('players', 'Manager')
      expect(options.table_name).to eq('players')
    end
  end
end

describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Player < SQLObject
      belongs_to :manager, foreign_key: :manager_id

      finalize!
    end

    class Manager < SQLObject
      self.table_name = 'managers'

      has_many :players, foreign_key: :manager_id
      belongs_to :team

      finalize!
    end

    class Team < SQLObject
      has_many :managers

      finalize!
    end
  end

  describe '#belongs_to' do
    let(:degrom) { Player.find(1) }
    let(:terry) { Manager.find(1) }

    it 'fetches `manager` from `Player` correctly' do
      expect(degrom).to respond_to(:manager)
      manager = degrom.manager

      expect(manager).to be_instance_of(Manager)
      expect(manager.fname).to eq('Terry')
    end

    it 'fetches `team` from `Manager` correctly' do
      expect(terry).to respond_to(:team)
      team = terry.team

      expect(team).to be_instance_of(Team)
      expect(team.name).to eq('Mets')
    end

    it 'returns nil if no associated object' do
      desmond = Cat.find(5)
      expect(desmond.manager).to eq(nil)
    end
  end

  describe '#has_many' do
    let(:dusty) { Human.find(3) }
    let(:dusty_team) { Team.find(3) }

    it 'fetches `players` from `Manager`' do
      expect(dusty).to respond_to(:players)
      players = dusty.players

      expect(players.length).to eq(1)

      expected_player_names = %w(Harper Scherzer)
      2.times do |i|
        player = players[i]

        expect(player).to be_instance_of(Player)
        expect(player.name).to eq(expected_cat_names[i])
      end
    end

    it 'fetches `managers` from `Team`' do
      expect(dusty_team).to respond_to(:managers)
      managers = dusty_team.managers

      expect(managers.length).to eq(1)
      expect(managers[0]).to be_instance_of(Managers)
      expect(managers[0].fname).to eq('Dusty')
    end

    it 'returns an empty array if no associated items' do
      playerless_manager = Manager.find(4)
      expect(playerless_manager.players).to eq([])
    end
  end

  describe '::assoc_options' do
    it 'defaults to empty hash' do
      class TempClass < SQLObject
      end

      expect(TempClass.assoc_options).to eq({})
    end

    it 'stores `belongs_to` options' do
      cat_assoc_options = Cat.assoc_options
      human_options = cat_assoc_options[:human]

      expect(human_options).to be_instance_of(BelongsToOptions)
      expect(human_options.foreign_key).to eq(:owner_id)
      expect(human_options.class_name).to eq('Human')
      expect(human_options.primary_key).to eq(:id)
    end

    it 'stores options separately for each class' do
      expect(Cat.assoc_options).to have_key(:human)
      expect(Human.assoc_options).to_not have_key(:human)

      expect(Human.assoc_options).to have_key(:house)
      expect(Cat.assoc_options).to_not have_key(:house)
    end
  end

  describe '#has_one_through' do
    before(:all) do
      class Cat
        has_one_through :home, :human, :house

        self.finalize!
      end
    end

    let(:cat) { Cat.find(1) }

    it 'adds getter method' do
      expect(cat).to respond_to(:home)
    end

    it 'fetches associated `home` for a `Cat`' do
      house = cat.home

      expect(house).to be_instance_of(House)
      expect(house.address).to eq('26th and Guerrero')
    end
  end
end
